IMPORT Std.Str AS S;
IMPORT $.Layout AS LA;
IMPORT * FROM Std.File;
IMPORT $.DeclareData AS D;

EXPORT File_Bible := MODULE

    LA.Layout_Verse Split(LA.Basic_Layout L) := TRANSFORM
        // Skip empty lines, and record the BOOK name as a record with 0 Chapter and 0 Verse, for easy identification on 2nd pass.
        BOOLEAN BOOKNAME := IF(LENGTH(TRIM(L.Text,LEFT,RIGHT))=0,SKIP,S.Find(L.Text,':')=0);    // No ':' for book identifiers
        SELF.Book    := '';     // A Place holder to be filled on on 2nd pass.
        SELF.Chapter := IF(BOOKNAME,0,(UNSIGNED1)L.Text[1..S.Find(L.Text,':',1)]);
        SELF.Verse   := IF(BOOKNAME,0,(UNSIGNED1)L.Text[S.Find(L.Text,':',1)+1..S.Find(L.Text,':',2)]);
        SELF.Text    := IF(BOOKNAME,TRIM(L.Text,LEFT,RIGHT),TRIM(L.Text[S.Find(L.Text,':',2)+1..],LEFT,RIGHT));
        SELF.Testament := L.Testament;
    END;

    BiblePass1 := PROJECT(D.Bible,Split(LEFT));;

    LA.Layout_Verse AddBookToEveryRecord(LA.Layout_Verse L,LA.Layout_Verse R) := TRANSFORM
        SELF.Book := IF(R.Chapter=0,R.Text,L.Book);
        SELF      := R;
    END;
    
    SHARED AllData := ITERATE(BiblePass1,AddBookToEveryRecord(LEFT,RIGHT))(Chapter!=0);
    
    // Base file does not need the 'Testament' as that will be a key.
    // Consequently tap off Testament information in a way that it can be joined to the Key constructed in 'inversion'.
    // Then its safe to drop the 'Testament' information from the Base file
    SHARED RNoTestament := RECORD
        Book    := AllData.Book;
        Chapter := AllData.Chapter;
        Verse   := AllData.Verse;
        Text    := AllData.Text;
    END;
     
    EXPORT Bld   := OUTPUT(TABLE(AllData,RNoTestament),,D.Base,OVERWRITE);
    EXPORT Bible := DATASET(D.Base,{RNoTestament,UNSIGNED8 Basepos {virtual(fileposition)}},FLAT);
    
    EXPORT RTestamentOnly := RECORD
       STRING1 Testament;
       UNSIGNED8 Basepos;
    END;

    RTestamentOnly ExtractTestament(Bible L,AllData R) := TRANSFORM
        SELF.Testament := R.Testament;
        SELF.Basepos := L.BasePos;          // Use BasePos as the link back to the information used in constructing the key.
    END;
    
    EXPORT TestamentOnly := JOIN(Bible,AllData,LEFT.Book = RIGHT.Book AND
                                               LEFT.Chapter = RIGHT.Chapter AND
                                               LEFT.Verse = RIGHT.Verse,ExtractTestament(LEFT,RIGHT));
END;
