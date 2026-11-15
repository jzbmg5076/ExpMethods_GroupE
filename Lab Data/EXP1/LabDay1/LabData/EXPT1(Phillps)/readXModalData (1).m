function [dt,X] = readXModalData (filename)

uf = load(filename);

dt = uf.UFCELLS{3}.AbscissaIncrement;
X  = uf.UFCELLS{3}.DataValues;

return