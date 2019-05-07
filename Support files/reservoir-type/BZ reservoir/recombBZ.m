function l = recombBZ(w,l,config)

Winner= w.a(:);
Loser = l.a(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.a = reshape(Loser,size(l.a));

Winner= w.b(:);
Loser = l.b(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.b = reshape(Loser,size(l.b));

Winner= w.c(:);
Loser = l.c(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.c = reshape(Loser,size(l.c));


Winner= w.w_in(:);
Loser = l.w_in(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.w_in = reshape(Loser,size(l.w_in));

Winner= w.input_loc;
Loser = l.input_loc;
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.input_loc = Loser;

if config.evolvedOutputStates
    Winner= w.state_loc;
    Loser = l.state_loc;
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.state_loc = Loser;
end