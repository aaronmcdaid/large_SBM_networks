import sys
import networkx as nx
import random
def write_network(K,O, desired_edges):
	N = K*O
	print "N=", N
	if(desired_edges == -1):
		desired_edges = N*N
	#G=nx.DiGraph(); G.add_edges_from([(i*O+n,j*O+m) for i in range(K) for j in range(K) for p in [random.random()] for n in range(O) for m in range(O) if random.random()<p ])
	#plt.cla(); plt.imshow(pylab.asarray(nx.convert.to_numpy_matrix(G)), interpolation='nearest')
	#nx.write_edgelist(G, "edge_list.txt")
	fEdges = open("edge_list.txt", "w")
	E=0
	for i in range(K):
		for j in range(K):
			p = random.random() * 2.*desired_edges / (N*N)
			for n in range(O):
				for m in range(O):
					if random.random()<p:
						src, tgt = (i*O+n,j*O+m)
						print >> fEdges, src, tgt
						E = E+1
	fGT = open("GT.vector", "w")
	for k in range(K):
		for o in range(O):
			print >> fGT , k
	print "E=", E

def main():
	K=int(sys.argv[1])
	O=int(sys.argv[2])
	desired_edges=int(sys.argv[3])
	random.seed(K+O)
	print (K)
	print (O)
	write_network(K,O, desired_edges)



main()

