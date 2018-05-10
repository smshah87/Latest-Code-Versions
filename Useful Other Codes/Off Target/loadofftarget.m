function [rawfound, points, calledpercell] =  loadofftarget(PathName, field)

A = load([PathName '\Pos' num2str(field) '\pos' num2str(field) 'PointsBarcodesrad6ScaledOn.mat']);
B = load([PathName '\Pos' num2str(field) '\pos' num2str(field) 'Barcodesrad6ScaledOn.mat']);
rawfound = B.rawfound;
points = A.points;
%copynumfinalsum = B.copynumfinalsum;
copynumfinalrevised = B.copynumfinalrevised;
calledpercell = sum(cell2mat(copynumfinalrevised(:,2:end)));

