function [dt,X] = readXModalData (test2settled)
uf = load(test2settled);
dt = uf.UFCELLS{3}.AbscissaIncrement;
X = uf.UFCELLS{3}.DataValues;
return
