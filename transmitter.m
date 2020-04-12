% total msg = start + data
Mt = [Ms;Md(:,1)];             % here w've chosen the first msg in Md

% msg as symbols -1,1 for bits 0,1
Mt(Mt==0)=-1;

