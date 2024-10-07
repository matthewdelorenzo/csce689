import math
import random as rd
import collections
from unicodedata import name
import numpy as np
import os, shutil
import os.path as osp
import torch
import time
from transformers import AutoTokenizer, AutoModelForCausalLM
from LLMQueryEnv_og import LLMQueryEnv
import json
# Exploration constant
c_PUCT = 1.38
# Dirichlet noise alpha parameter.
D_NOISE_ALPHA = 0.03
# Number of steps into the episode after which we always select the
# action with highest action probability rather than selecting randomly
TEMP_THRESHOLD = 5
CHILD_TYPE = 'robust'


class DummyNode:
    """
    Special node that is used as the node above the initial root node to
    prevent having to deal with special cases when traversing the tree.
    """

    def __init__(self):
        self.parent = None
        self.child_N = collections.defaultdict(float)
        self.child_W = collections.defaultdict(float)
        self.child_M = collections.defaultdict(float)

    def revert_visits(self, up_to=None): pass

    def backup_value(self, predValue,actualValue,up_to=None): pass


class MCTSNode:
    def __init__(self,state,n_actions, TreeEnv, action=None, parent=None,childType='robust'):
        self.TreeEnv = TreeEnv
        if parent is None:
            self.depth = 0
            parent = DummyNode()
        else:
            self.depth = parent.depth+1
        self.parent = parent
        self.action = action
        self.state = state
        self.n_actions = n_actions
        self.is_expanded = False
        self.childType = childType

        self.n_vlosses = 0  
        self.child_N = np.zeros([n_actions], dtype=np.float32)
        self.child_W = np.zeros([n_actions], dtype=np.float32)
        self.child_M = np.zeros([n_actions], dtype=np.float32)
        self.original_prior = np.zeros([n_actions], dtype=np.float32)
        self.child_prior = np.zeros([n_actions], dtype=np.float32)
        self.child_visited = np.zeros([n_actions], dtype=np.int32)
        self.child_ids = np.zeros([n_actions], dtype=np.int32)
        self.children = {}

    @property
    def N(self):
        """
        Returns the current visit count of the node.
        """
        return self.parent.child_N[self.action]

    @N.setter
    def N(self, value):
        self.parent.child_N[self.action] = value

    @property
    def W(self):
        """
        Returns the current total value of the node.
        """
        return self.parent.child_W[self.action]

    @W.setter
    def W(self, value):
        self.parent.child_W[self.action] = value
        
    @property
    def M(self):
        """
        Returns the current total value of the node.
        """
        return self.parent.child_M[self.action]

    @M.setter
    def M(self, value):
        self.parent.child_M[self.action] = value

    @property
    def Q(self):
        """
        Returns the current action value of the node.
        """
        return self.W / (1 + self.N)
    
    @property
    def averagedMonteCarlo(self):
        """
        Returns the averaged montecarlo value of the node.
        """
        return self.M / (1 + self.N)
    
    @property
    def child_averagedMonteCarlo(self):
        return self.child_M / (1 + self.child_N)

    @property
    def child_Q(self):
        return self.child_W / (1 + self.child_N)

    @property
    def child_U(self):
        return (c_PUCT * math.sqrt(1 + self.N) *
                self.child_prior / (1 + self.child_N))

    @property
    def child_action_score(self):
        return self.child_averagedMonteCarlo + self.child_U
    
    
    def select_leaf(self):
        current = self
        while True:
            print("Leaf selection - depth: ", current.depth)
            if not current.is_expanded:
                break
            print("Leaf selection - action scores: ", current.child_action_score, " taking action: ", np.argmax(current.child_action_score))
            best_move = np.argmax(current.child_action_score)
            current = current.maybe_add_child(best_move)
        return current

    def select_leaf_during_evaluation(self,childType='robust'):
        current = self
        while True:
            if not current.is_expanded:
                break
            if self.childType == 'max':
                best_move = np.argmax(current.child_averagedMonteCarlo)
            else:
                best_move = np.argmax(current.child_N)
            current = current.maybe_add_child(best_move)
        return current


    def maybe_add_child(self, action):
        if action not in self.children:
            # Obtain state following given action.
            print("Adding child.")
            new_state = self.TreeEnv.next_state(self.state,self.child_ids[action])
            self.children[action] = MCTSNode(new_state,self.n_actions,
                                             self.TreeEnv,
                                             action=action, parent=self,childType=self.childType)
            self.child_visited[action] = 1
        return self.children[action]
        
    def incorporate_estimates(self,action_probs,predValue,actualValue,up_to):

        self.is_expanded = True
        self.original_prior = self.child_prior = action_probs
 
        self.child_W = np.zeros([self.n_actions], dtype=np.float32)
        self.child_M = np.zeros([self.n_actions], dtype=np.float32)
        self.backup_value(predValue,actualValue,up_to=up_to)

    def backup_value(self, predValue,actualValue, up_to):
        """
        Propagates a value estimation up to the root node.
        :param value: Value estimate to be propagated.
        :param up_to: The node to propagate until.
        """
        self.W += predValue
        self.M += actualValue
        self.N += 1
        if self.parent is None or self is up_to:
            return
        self.parent.backup_value(predValue,actualValue,up_to)

    def is_done(self):
        return self.TreeEnv.is_done_state(self.state,self.depth)

    def inject_noise(self):
        self.child_prior = np.array(self.child_prior)
        dirch = np.random.dirichlet([D_NOISE_ALPHA] * self.n_actions)
        print(type(self.child_prior))
        print(type(dirch))
        self.child_prior = self.child_prior * 0.85 + dirch * 0.15
        

    def visits_as_probs(self, squash=False):
        if self.childType == 'max':
            probs = self.child_averagedMonteCarlo # MCTS max child
        else:
            probs = self.child_N # MCTS robust child
        if squash:
            probs = probs ** .95
        return probs / np.sum(probs)
    
    def print_bfs_tree(self, level=0):
        self.printNodeInfo(level)
        listOfNodesToPrint = []
        for _, child in sorted(self.children.items()):
            listOfNodesToPrint.append((child,level+1))
        while len(listOfNodesToPrint)>0:
            childNode,depth = listOfNodesToPrint.pop(0)
            childNode.printNodeInfo(depth)
            for _, child in sorted(childNode.children.items()):
                listOfNodesToPrint.append((child,depth+1))
            
    def printNodeInfo(self,level):
        node_string = "----"
        node_string += "\n Tree depth: {}".format(level)
        node_string += "\n Node: action={}".format(self.action)
        node_string += "\n• state:{}".format(self.state)
        node_string += "\n• Child Action scores:{}".format(self.child_action_score)
        node_string += "\n• Child averaged monte carlo:{}".format(self.averagedMonteCarlo)
        node_string += "\n• Child probablities:{}".format(self.child_prior)
        node_string += "\n• Child visitation:{}".format(self.child_visited)
        node_string += "\n• N={},Q={},M={}".format(self.N,self.Q,self.averagedMonteCarlo)
        print(node_string)

    def print_tree(self, level=0):
        node_string = "\033[94m|" + "----"*level
        node_string += "\n Node: action={}\033[0m".format(self.action)
        node_string += "\n• state:\n{}".format(self.state)
        node_string += "\n• Child Action scores:\n{}".format(self.child_action_score)
        node_string += "\n• Child visitation:\n{}".format(self.child_visited)
        node_string += "\n• N={},Q={},M={}".format(self.N,self.Q,self.averagedMonteCarlo)
        print(node_string)
        for _, child in sorted(self.children.items()):
            child.print_tree(level+1)


class MCTS:
    def __init__(self, TreeEnv, childType='robust',
                 simulations_per_move=800, num_parallel=4):
        self.TreeEnv = TreeEnv
        self.childType = childType
        self.simulations_per_move = simulations_per_move
        self.num_parallel = num_parallel
        self.temp_threshold = None        # Overwritten in initialize_search
        self.isFirstExploration = True
        self.root = None
        self.num_simulations = 0

    def initialize_search(self, state=None):
        init_state = self.TreeEnv.get_initial_state()
        n_actions = self.TreeEnv.n_actions
        print("Initialize search (creating root node)", end='\n\n')
        self.root = MCTSNode(init_state,n_actions, self.TreeEnv,childType=self.childType)
        # Number of steps into the episode after which we always select the
        # action with highest action probability rather than selecting randomly
        self.temp_threshold = TEMP_THRESHOLD

    def tree_search(self):    
        print("MCTS Stage 1 - Selection: finding leaf node.", end='\n\n')
        leaf = self.root.select_leaf()
        if leaf.is_done():
            print("Leaf is terminal - getting return value.")
            value = self.TreeEnv.get_return(leaf.state,leaf.depth)
            print("MCTS Stage 4 - Backpropogation: incorporating estimates.", end='\n\n')
            leaf.backup_value(value,value,up_to=self.root)
        else:
            print("Getting LLM token estimates (probs/ids).")
            probs, ids = self.TreeEnv.getLLMestimates(leaf.state)
            leaf.child_ids = ids
            startingAction = leaf.child_ids[np.argmax(probs)]
            print("MCTS Stage 2 - Expansion: next action: ", np.argmax(probs), " corresponding to state: ", startingAction, end='\n\n')
            next_state = self.TreeEnv.next_state(leaf.state,startingAction)
            print("MCTS Stage 3 - Rollout: Getting rollout return of leaf.", end='\n\n')
            rolloutReturn = self.TreeEnv.get_montecarlo_return(next_state,leaf.depth+1)
            print("MCTS Stage 4 - Backpropogation: incorporating estimates.", end='\n\n')
            leaf.incorporate_estimates(probs,rolloutReturn,rolloutReturn,up_to=self.root)
            
    def test_tree_search(self,cType):
        ## This should not backup value since we are only traversing to the leaf node based
        ## on robust-child or max-child and return the value
        leaf = self.root.select_leaf_during_evaluation(cType)
        if leaf.is_done():
            value = self.TreeEnv.get_return(leaf.state,leaf.depth)
        else:
            probs, ids = self.TreeEnv.getLLMestimates(leaf.state)
            leaf.child_ids = ids
            startingAction = leaf.child_ids[np.argmax(probs)]
            next_state = self.TreeEnv.next_state(leaf.state,startingAction)
            value = self.TreeEnv.get_montecarlo_return(next_state,leaf.depth+1)
            
        return value


def initialize_MCTS_tree(TreeEnv):
    print("Initializing MCTS tree.")
    mcts = MCTS(TreeEnv,childType=CHILD_TYPE)
    mcts.initialize_search()
    print("MCTS Stage 1 - Selection: finding leaf node.", end='\n\n')
    first_node = mcts.root.select_leaf()
    print("Getting LLM token estimates (probs/ids).")
    probs, ids = TreeEnv.getLLMestimates(first_node.state)

    ## Compute montecarlo return using the policy's first best move followed by random rather than entirely random policy
    first_node.child_ids = ids
    startingAction = first_node.child_ids[np.argmax(probs)]
    print("MCTS Stage 2 - Expansion: next action: ", np.argmax(probs), " corresponding to state: ", startingAction, end='\n\n')
    next_state = TreeEnv.next_state(first_node.state,startingAction)
    print("MCTS Stage 3 - Rollout: Getting rollout return of leaf.", end='\n\n')
    first_node_rolloutReturn = TreeEnv.get_montecarlo_return(next_state,first_node.depth+1) #resyn2 output will lead to DRAW or 0.
    print("MCTS Stage 4 - Backpropogation: incorporating estimates.", end='\n\n')
    first_node.incorporate_estimates(probs, first_node_rolloutReturn, first_node_rolloutReturn,first_node)
    mcts.root.inject_noise()
    return mcts

def initialize_thread_tree(index, prompt_str, problem_name, file_dir, model_name, tokenizer, model):
    # Create a partially applied function with the required parameters
    return initialize_MCTS_tree(
        LLMQueryEnv(orig_prompt=prompt_str, orig_module=problem_name, file_path=file_dir,
                    model_name=model_name, tokenizer=tokenizer, model=model)
    )

def execute_episode(mctsTree,simulation_budget):
    file_name = "mcts_vgen16b/output" + ".jsonl"
    with open(file_name, 'w') as output_file:
        mctsTree.num_simulations += 1
        current_runs = mctsTree.root.N
        while mctsTree.root.N < current_runs+simulation_budget:
            if mctsTree.root.N > 0 and mctsTree.root.N % 100 == 0:
                print("ROBUST FINAL VALUE, ITERATION: ", current_runs)
                evalMctsRobustValue, evalMctsMaxValue = test_episode(mctsTree)
            start_time = time.process_time()
            mctsTree.tree_search()
            end_time = time.process_time()
            print("-------------------------------------------------------")
            print("MCTS Iteration: ", mctsTree.root.N)
            elapsed_time = end_time - start_time
            print("Iteration TIME (sec): ", elapsed_time)
            mctsTree.TreeEnv.row_data['episode'] = mctsTree.num_simulations
            mctsTree.TreeEnv.row_data['currentRun'] = mctsTree.root.N
            #output_data = {"task_id": task_id, "completion": output}
            #output_file.write(json.dumps(output_data) + '\n')
            mctsTree.TreeEnv.csv_logger.log(mctsTree.TreeEnv.row_data)

        mctsTree.root.print_bfs_tree()
    return mctsTree

def test_episode(mctsTree):
    mctsEvalMaxValue = mctsTree.test_tree_search(cType='max')
    mctsEvalRobustValue = mctsTree.test_tree_search(cType='robust')
    return mctsEvalRobustValue, mctsEvalMaxValue


        