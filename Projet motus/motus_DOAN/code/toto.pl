
animal(chien).
animal(chat).
prenom(paul).
prenom(pierre).
prenom(jean).

imprime([]) :- write(cc).
imprime([T|Q]) :- write(T), nl, imprime(Q).


element(X, [X|_]).
element(X, [_|Q]) :- element(X, Q).

concat([],L,L).
concat([T|Q],L,[T|R]):-concat(Q,L,R).

renverser([], L, L).
renverser([T|Q], L, R) :- renverser(Q, [T|L], R).
fonc(Mots,0,Char):-
    read_atom(Mots),
    sub_atom(Mots,0,1,_,Char),
    write(Char)
    .

fonc(Mots,L,Char):-

    L0 is L-1,
    fonc(Mots,L0,Char),
    write(Char)
    .

start :-
    read_atom(Mots),
    read_from_atom(Mots,X),
    write(X)
    .

% if uppercase get lowercase

make_lower(C,   L) :- upper_lower(C, L) ; L = C.
