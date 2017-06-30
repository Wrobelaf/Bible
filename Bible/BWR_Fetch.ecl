IMPORT * FROM $.Inversion;
IMPORT * from $.File_Bible;

//itm := $.Inversion.Get(['N','O'],'GOD',13,'KINGDOM');
//itm := $.Inversion.Get(['N','O'],'GOD');

//itm := Search('SOLITARY',['O']);
//itm := Key(WORD='SOLITARY',Testament='O');
//itm :=FETCH(Bible,Key(WORD='SOLITARY'),RIGHT.Basepos);
itm :=FETCH(Bible,Key(WORD='HYSSOP'),RIGHT.Basepos);
OUTPUT(itm);