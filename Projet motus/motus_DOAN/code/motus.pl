/* =======================================================================*/
/*  -------------------- Projet IA02 P19 : Le Motus ----------------------*/
/* =======================================================================*/
/*                            DOAN Nhat-Minh TC01                         */
/* =======================================================================*/
/*                            FONCTIONS UTILES                            */
/* =======================================================================*/
% Built-in predicats
/*    -   append(List1, List2, List12) succeeds if the concatenation of the
    list List1 and the list List2 is the list List12.
    -   permutation(List1, List2) succeeds if List2 is a permutation of the
    elements of List1.
    -   atom_codes(Atom, Codes) succeeds if Codes is the list of code ascii
    of the successive characters of the name of Atom.
    -   consult(File).
    -   atom_length(Atom, Length) succeeds if Length unifies with the number
    of characters of the name of Atom.
    -   number_atom(Number, Atom) succeeds if Atom is an atom whose name
    corresponds to the characters of Number.
    -   nth(N, List, Element) succeeds if the Nth argument of List is
    Element.
    -   read_atom(Atom) succeeds if Atom unifies with the next atom
    read from the stream associated with the current straem.
    -   member(Element, List) succeeds if Element belongs to the List.
    -   random(Base, Max, Number) unifies Number with a random number such
    that Base ≤ Number < Max.
    -   sublist(List1, List2) succeeds if all elements of List1 appear in
    List2 in the same order.
    -   reverse(List1, List2) succeeds if List2 unifies with the list
    List1 in reverse order.
    -   delete(List1, Element, List2) removes all occurrences of Element
    in List1 to provide List2.
    -   length(List, Integer) succeeds if Integer is the length of List*/
% Fonctions utiles
%% Uppercase tous les caracteres (code ascii)
majuscule([], []) :-!.
majuscule([L|LCodes], [U|UCodes]) :-
    (
        L >= 65,
        L =< 90,
        U is L,
        !;
        U is L-32,!
    ),
    majuscule(LCodes, UCodes).
%% Effacer les elements de L1 dans L2 pour obtenir L3 (une seul ocurrence
%% chaque element)
delete1_list(L1,L2,L3):-
    append(L1,L3,L),
    permutation(L,L2),
    !.
%% Consulter le fichier mots
consulte_fichier(Char1_Lenth):-
    % Car le fichier dico.pl est tres gros, je ne consulte que le ficher
    % dont le nom commencant par la lettre Char1, la longueur du mot est
    % Lenth. par exemple 'P5.pl'
    append(Char1_Lenth,[46,112,108],CodesNomFichier), % [46,112,108] : ['.','p','l']
    atom_codes(NomFichier,CodesNomFichier),
    consult(NomFichier).

%% Donner les informations necessaires d'un mot
information_mot(Mot,UCodes,Lenth,CodesAtomLenth,CodeChar1):-
    atom_codes(Mot,Codes),% Codes : liste des caracteres (code ascii)
    atom_length(Mot,Lenth), % Lenth : longueur du atom
    number_atom(Lenth,AtomLenth), % AtomLenth : Lenth sous type atom
    atom_codes(AtomLenth,CodesAtomLenth), % CodesAtomLenth : le code ascii de AtomLenth
    majuscule(Codes,UCodes),
    nth(1, UCodes, CodeChar1). % 1ere caractere

valide(Mot):-
    information_mot(Mot,UCodes,Lenth,CodesAtomLenth,CodeChar1),
    append([CodeChar1],CodesAtomLenth,NomFichier),
    consulte_fichier(NomFichier),
    (
        dico([CodeChar1], Lenth, UCodes);write('Ce mot n''est pas dans le dictionnaire, ressayez !:'),nl,fail
    ).
%% calculer le nombre d'occurrences d'un element
countt(_,[],0).
countt(A,[A|L],N):- !,countt(A,L,N1),N is N1+1.
countt(A,[_|L],N):- countt(A,L,N),!.
countt(A,[B|L],N):- countt(A,B,N1),countt(A,L,N2),N is N1+N2.
%% afficher seulement le 1ere caractere et la longueur du mot
afficher1(_,0):-!.
afficher1(CodeChar1,1):-
    atom_codes(Char1,[CodeChar1]),
    write(Char1),!.
afficher1(CodeChar1,Lenth):-

    L is Lenth-1,
    afficher1(CodeChar1,L),
    write('.').
%% lire un mot de calavier
lire_mot(MotCherche,UCodesMotCherche,Lenth,CodeChar1):-
    repeat,
        write('Votre proposition :'),
        read_atom(MotCherche),

        %write(LenthMotCherche),nl,
        (
            atom_length(MotCherche,Lenth),
            atom_codes(MotCherche,CodesMotCherche),
            majuscule(CodesMotCherche,UCodesMotCherche),
            nth(1, UCodesMotCherche, CodeChar1),
            dico([CodeChar1],Lenth,UCodesMotCherche),
            atom_codes(UMot,UCodesMotCherche),write(UMot),nl;
            write('La taille du mot ou la 1ere caractere ou la validite n''est pas bonne ! re-essayez:'),nl,
            fail
        ),!.

%% verifier le mot choisi ne contient pas des caracteres donnees dans ListeCharNot
verifier_charNot(_,[]):-!.

verifier_charNot(ListeCharNot,[TCodesMot|QCodesMot]):-
    verifier_charNot(ListeCharNot,QCodesMot),
    \+member(TCodesMot,ListeCharNot).

%% choisir un mot valide dans la dictionnaire

choisir_mot(CodeChar1,Lenth,ListeChar,ListeCharNot,CodesMot):-
    dico([CodeChar1], Lenth, CodesMot),
    permutation(ListeChar,X),
    sublist(X,CodesMot),
    verifier_charNot(ListeCharNot,CodesMot).

%% verifier si le mot devine est correct
correct([],[]):-!.
correct([TCodesMot|QCodesMot],[TCodesMotCherche|QCodesMotCherche]):-
    (
        TCodesMot is TCodesMotCherche,
        correct(QCodesMot,QCodesMotCherche),
        !;
        fail,
        !
    ).
%% donner la liste contenant des caracteres qui appartiennent das le mot et sont dans la bonne proposition (bonne caractere bonne position)
bcbp([],[],[]):-!.
bcbp([TCodesMot|QCodesMot],[TCodesMotCherche|QCodesMotCherche],[T|Q]):-
    bcbp(QCodesMot,QCodesMotCherche,Q),
    (
        TCodesMot = TCodesMotCherche,
        T is TCodesMot,
        !;
        T = 43,
        !
    ).
%% donner la liste contenant des caracteres qui appartiennent das le mot et ne sont pas dans la bonne proposition (bonne caractere mauvais position)
%% ListeRest est la liste des caracteres du mot qui n'appartiennent pas dans la liste bcbp
bcmp(_,[],[],_,[],[],_):-!.
bcmp(CodesMot,[TCodesMot|QCodesMot],[TCodesMotCherche|QCodesMotCherche],ListeRest,[T|Q],[T1|Q1],Listebcbp):-
    bcmp(CodesMot,QCodesMot,QCodesMotCherche,ListeRest,Q,Q1,Listebcbp),
    (
        \+TCodesMot = TCodesMotCherche,
        member(TCodesMotCherche,ListeRest),
        countt(TCodesMotCherche,Listebcbp,N1),
        countt(TCodesMotCherche,ListeRest,N2),
        %countt(TRCodesMotCherche,QRCodesMotCherche,N3),
        countt(TCodesMotCherche,[TCodesMotCherche|QCodesMotCherche],N3),
        N31 = N3 - N1,
        N21 = N2 - N1,
        (
            N31 @=< N21,
            T is TCodesMotCherche;
            N31 @> N21,
            T = 43
        ),

        T1 = 43,
        !;
        (
            \+TCodesMot = TCodesMotCherche,
            \+member(TCodesMotCherche,ListeRest),
            T = 43,
            (
                \+member(TCodesMotCherche,CodesMot),
                T1 = TCodesMotCherche,

                !;
                member(TCodesMotCherche,CodesMot),
                T1 = 43,!
            ),
            !;
            TCodesMot = TCodesMotCherche,
            T = 43,
            T1 = 43,
            !
        )
    ).

%% generer les listes et afficher les "?" "!" "."
check(CodesMot,CodesMotCherche,Liste5,ListeNot):-
    reverse(CodesMot,RCodesMot),
    reverse(CodesMotCherche,RCodesMotCherche),

    bcbp(CodesMot,CodesMotCherche,Liste1),
    delete(Liste1,43,Liste2),
    delete1_list(Liste2,CodesMot,ListeRest),
    bcmp(CodesMot,CodesMot,CodesMotCherche,ListeRest,Liste3,ListeNot3,Liste2),
    delete(Liste3,43,Liste4),
    delete(ListeNot3,43,ListeNot),
    append(Liste2,Liste4,Liste5),
    afficher(RCodesMot,RCodesMotCherche,ListeRest,Liste2),
    nl,
    !.
%% afficher les "?" "!" "."
afficher([],[],_,_):-!.

afficher([TRCodesMot|QRCodesMot],[TRCodesMotCherche|QRCodesMotCherche],ListeRest,Listebcbp):-
    afficher(QRCodesMot,QRCodesMotCherche,ListeRest,Listebcbp),
    (
        TRCodesMot = TRCodesMotCherche,
        write('!'),!;
        (
            \+TRCodesMot = TRCodesMotCherche,
            member(TRCodesMotCherche,ListeRest),
            countt(TRCodesMotCherche,Listebcbp,N1),
            countt(TRCodesMotCherche,ListeRest,N2),
            countt(TRCodesMotCherche,[TRCodesMotCherche|QRCodesMotCherche],N3),
            N31 = N3 - N1,
            N21 = N2 - N1,
            (
                N31 @=< N21,
                write('?');
                N31 @> N21,
                write('.')
            ),!;
            \+TRCodesMot = TRCodesMotCherche,
            \+member(TRCodesMotCherche,ListeRest),
            write('.'),!
        )
    ).

% Creation d'une menu
start :-
    % repeats menu and prompts for input of command
    write('M O T U S !'), nl,
    write('---------------------'), nl,
    write('Qui joue ?'),nl,
    repeat,
    write('  o - ordinateur'), nl,
    write('  h - humain'), nl,
    write('  x - exit'), nl,
    write('Command (Syntax: [caractere] + [entree]): '),nl,
    read_atom(CommandCode),
    (
        member(CommandCode,[o,h,x]);write('Syntax non valide'),nl,fail
    ),!,
    menu(CommandCode),
    !.
% espace ordinateur
menu(Command) :-
    Command = o,
    write('Ordinateur pret !'), nl,
    write('---------------------'), nl,
    write('Mot a deviner (donnez le mot tous minuscules):'),nl,

    repeat,
        read_atom(Mot),%read atom,
        atom_codes(Mot,Codes),majuscule(Codes,UCodes),atom_codes(UMot,UCodes),
    valide(Mot),!,
    write('Mot a deviner :'),nl,
    write(UMot),
    ordinateur(Mot),
    !.
% espace humain
menu(Command) :-
    Command = h,
    nl,
    write('Humain pret !'),nl,
    write('---------------------'), nl,
    random(65,91,CodeChar1),
    random(5,11,Lenth),

    repeat,
        random(65,91,Code),
        %write(Code),nl,
        (
            Code=65;
            (
                Code=69;
                (
                    Code=73;
                    (
                        Code=79;
                        (
                            Code=85;
                            Code=89
                        )
                    )
                )
            )
        ),
        !,
    repeat,
        random(65,91,CodeNot),
        %write(CodeNot),nl,
        (
            CodeNot=65;
            (
                CodeNot=69;
                (
                    CodeNot=73;
                    (
                        CodeNot=79;
                        (
                            CodeNot=85;
                            CodeNot=89
                        )
                    )
                )
            )
        ),
        \+CodeNot = Code,
        !,
    number_atom(Lenth,AtomLenth), % AtomLenth : Lenth sous type atom
    atom_codes(AtomLenth,CodesAtomLenth),
    append([CodeChar1],CodesAtomLenth,NomFichier),
    consulte_fichier(NomFichier),
    choisir_mot(CodeChar1,Lenth,[Code],[CodeNot],CodesMotSecret),!,
    atom_codes(MotSecret,CodesMotSecret),
    write(MotSecret),nl,
    write('La longueur du mot est: '),
    write(Lenth),nl,
    afficher1(CodeChar1,Lenth),nl,
    %majuscule(Mot,MotSecret),
    humain(CodesMotSecret),
    !.
% exit
menu(Command) :-
    Command = x,
    nl,
    write('exit'),
    !.
% fonction humain
humain(CodesMotSecret):-
    length(CodesMotSecret,Lenth),
    nth(1, CodesMotSecret, CodeChar1),
    %information_mot(Mot,MotSecret,Lenth,_,CodeChar1),
    lire_mot(_,UCodesMotCherche,Lenth,CodeChar1),
    check(CodesMotSecret,UCodesMotCherche,_,_),
    (
        correct(CodesMotSecret,UCodesMotCherche),
        write('Vous etes forte(e) !'),nl;
        lire_mot(_,UCodesMotCherche1,Lenth,CodeChar1),
        check(CodesMotSecret,UCodesMotCherche1,_,_),
        (
            correct(CodesMotSecret,UCodesMotCherche1),
            write('Vous etes forte(e) !'),nl;
            lire_mot(_,UCodesMotCherche2,Lenth,CodeChar1),
            check(CodesMotSecret,UCodesMotCherche2,_,_),
            (
                correct(CodesMotSecret,UCodesMotCherche2),
                write('Vous etes forte(e) !'),nl;
                lire_mot(_,UCodesMotCherche3,Lenth,CodeChar1),
                check(CodesMotSecret,UCodesMotCherche3,_,_),
                (
                    correct(CodesMotSecret,UCodesMotCherche3),
                    write('Vous etes forte(e) !'),nl;
                    lire_mot(_,UCodesMotCherche4,Lenth,CodeChar1),
                    check(CodesMotSecret,UCodesMotCherche4,_,_),
                    (
                        \+ Lenth = 5,
                        lire_mot(_,UCodesMotCherche5,Lenth,CodeChar1),
                        check(CodesMotSecret,UCodesMotCherche5,_,_),
                        (
                            correct(CodesMotSecret,UCodesMotCherche5),
                            write('Vous etes forte(e) !'),nl;
                            write('Pas correct !'),nl,
                            write('Le mot secret est :'),
                            atom_codes(Mot,CodesMotSecret),
                            write(Mot),nl
                        ),!;
                        (
                            correct(CodesMotSecret,UCodesMotCherche4),
                            write('Vous etes forte(e) !'),nl;
                            write('Pas correct !'),nl,
                            write('Le mot secret est :'),
                            atom_codes(Mot,CodesMotSecret),
                            write(Mot),nl
                        ),!
                    ),!
                ),!
            ),!
        ),!
    ),!.

% fonction ordinateur
ordinateur(Mot):-
    information_mot(Mot,UCodes,Lenth,_,CodeChar1),
    nl,
    write('AI hard'),nl,
    write('Propositions :'),nl,
    repeat,
        random(65,91,Code),
        %write(Code),nl,
        (
            Code=65;
            (
                Code=69;
                (
                    Code=73;
                    (
                        Code=79;
                        (
                            Code=85;
                            Code=89
                        )
                    )
                )
            )
        ),
        !,

        choisir_mot(CodeChar1,Lenth,[Code],[],CodesMotCherche),
        atom_codes(X,CodesMotCherche),
        write(X),nl,
        check(UCodes,CodesMotCherche,ListChar1,ListCharNot1),
        (
            correct(UCodes,CodesMotCherche),
            write('C''est facile ! - dit Ordi.'),nl,!;

            choisir_mot(CodeChar1,Lenth,ListChar1,ListCharNot1,CodesMotCherche1),
            \+permutation(CodesMotCherche,CodesMotCherche1),
            atom_codes(X1,CodesMotCherche1),
            write(X1),nl,
            check(UCodes,CodesMotCherche1,ListChar2,ListCharNot2),
            (
                correct(UCodes,CodesMotCherche1),
                write('C''est facile ! - dit Ordi.'),nl,!;

                append(ListCharNot1,ListCharNot2,ListCharNot12),
                choisir_mot(CodeChar1,Lenth,ListChar2,ListCharNot12,CodesMotCherche2),
                \+permutation(CodesMotCherche1,CodesMotCherche2),
                \+permutation(CodesMotCherche,CodesMotCherche2),
                atom_codes(X2,CodesMotCherche2),
                write(X2),nl,
                check(UCodes,CodesMotCherche2,ListChar3,ListCharNot3),
                (
                    correct(UCodes,CodesMotCherche2),
                    write('C''est facile ! - dit Ordi.'),nl,!;

                    append(ListCharNot12,ListCharNot3,ListCharNot23),
                    choisir_mot(CodeChar1,Lenth,ListChar3,ListCharNot23,CodesMotCherche3),
                    \+permutation(CodesMotCherche2,CodesMotCherche3),
                    \+permutation(CodesMotCherche1,CodesMotCherche3),
                    \+permutation(CodesMotCherche,CodesMotCherche3),
                    atom_codes(X3,CodesMotCherche3),
                    write(X3),nl,
                    check(UCodes,CodesMotCherche3,ListChar4,ListCharNot4),
                    (
                        correct(UCodes,CodesMotCherche3),
                        write('C''est facile ! - dit Ordi.'),nl,!;

                        append(ListCharNot23,ListCharNot4,ListCharNot34),

                        choisir_mot(CodeChar1,Lenth,ListChar4,ListCharNot34,CodesMotCherche4),
                        \+permutation(CodesMotCherche3,CodesMotCherche4),
                        \+permutation(CodesMotCherche2,CodesMotCherche4),
                        \+permutation(CodesMotCherche1,CodesMotCherche4),
                        \+permutation(CodesMotCherche,CodesMotCherche4),
                        atom_codes(X4,CodesMotCherche4),
                        write(X4),nl,
                        check(UCodes,CodesMotCherche4,ListChar5,ListCharNot5),
                        (
                            \+Lenth =5,
                            append(ListCharNot34,ListCharNot5,ListCharNot45),
                            choisir_mot(CodeChar1,Lenth,ListChar5,ListCharNot45,CodesMotCherche5),
                            \+permutation(CodesMotCherche4,CodesMotCherche5),
                            \+permutation(CodesMotCherche3,CodesMotCherche5),
                            \+permutation(CodesMotCherche2,CodesMotCherche5),
                            \+permutation(CodesMotCherche1,CodesMotCherche5),
                            \+permutation(CodesMotCherche,CodesMotCherche5),
                            atom_codes(X5,CodesMotCherche5),
                            write(X5),nl,
                            check(UCodes,CodesMotCherche5,ListChar6,ListCharNot6),
                            %append(ListCharNot45,ListCharNot6,ListCharNot56),
                            (
                                correct(UCodes,CodesMotCherche5),
                                write('C''est facile ! - dit Ordi.'),nl,!;
                                write('C''est dur ! - dit Ordi.'),nl,!
                            ),!;
                            (
                                correct(UCodes,CodesMotCherche4),
                                write('C''est facile ! - dit Ordi.'),nl,!;
                                write('C''est dur ! - dit Ordi.'),nl,!
                            ),!
                        ),!
                    ),!
                ),!
            ),!
        ),!.
