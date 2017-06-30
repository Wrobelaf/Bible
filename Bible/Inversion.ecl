IMPORT * FROM Std.Str;
IMPORT $.Layout AS LA;
IMPORT $.DeclareData AS D;
IMPORT $.File_Bible AS Base;

EXPORT Inversion := MODULE

    SHARED BaseDS := Base.Bible;
    SHARED Tonly  := Base.TestamentOnly;

    // Merge the Text with the 'Testament' Data to get all required data for the key.
    SHARED Layout_AllKeyData := RECORD
        LA.Testament;
        LA.Layout_Raw_Book;
        UNSIGNED8 Basepos {virtual(fileposition)};
    END;

    Layout_AllKeyData GetAllKeyData(BaseDS L,Tonly R) := TRANSFORM
        SELF.Testament := R.Testament;
        SELF := L;
    END;

    EXPORT AllKeyData := JOIN(BaseDS,Tonly,LEFT.BasePos = RIGHT.BasePos,GetAllKeyData(LEFT,RIGHT));

    // Now construct the inverted file from the text.
    SHARED R := RECORD
        STRING1   Testament := '';
        UNSIGNED1 Word_Pos  := 0;
        STRING50  Word      := '';
        UNSIGNED8 Basepos {virtual(fileposition)} := 0;
    END;

    SHARED R TakeWord(AllKeyData L,INTEGER C) := TRANSFORM
        SELF.Word_Pos := C;
        SELF.Word := ToUpperCase(GetNthWord($.Clean(L.Text),C));
        SELF := L;
    END;
    EXPORT Records := NORMALIZE(AllKeyData,WordCount($.Clean(LEFT.Text)),TakeWord(LEFT,COUNTER));

    EXPORT Key := INDEX(Records,{Testament,Word,Word_pos,Basepos},{},D.Key);
    EXPORT Bld := BUILDINDEX(Key,OVERWRITE);
    
    EXPORT Search(STRING S,BOOLEAN pNear=FALSE,BOOLEAN Old=TRUE,BOOLEAN New=TRUE) := FUNCTION

        UNSIGNED1 dis     := IF(pNear=FALSE,0,3);
        SET OF STRING1 t0 := IF(Old=TRUE,['O'],[]);
                       t1 := t0 + IF(New=TRUE,['N'],[]);
                       t2 := IF(t1=[],['O','N'],t1);

        BOOLEAN NEAR(UNSIGNED1 L,UNSIGNED1 R) := ((dis = 0) OR (dis != 0 AND (ABS(L-R) <= dis)));
        
        D := DATASET([{s}],{STRING T});
        
        R SearchBlock(D L,UNSIGNED C) := TRANSFORM
           SELF.Word := GetNthWord(L.T,C);
        END;
        
        N := NORMALIZE(D,WordCount(S),SearchBlock(LEFT,COUNTER));

        R GraphBody (SET OF DATASET(R) I,UNSIGNED C) := FUNCTION
            RETURN MAP(C = 1 => PROJECT(Key(Word=I[0][1].Word AND Testament IN t2),TRANSFORM(R,SELF := LEFT)),
                                JOIN(I[C-1],Key,RIGHT.Word=I[0][C].Word AND
                                                NEAR(LEFT.Word_Pos,RIGHT.Word_Pos) AND
                                                // Note 'Basepos' test means they must be in the same testament book chapter and verse
                                                LEFT.Basepos = RIGHT.Basepos,TRANSFORM(R,SELF := LEFT)
                                    )
                       );
        END;
        
        g1 := DEDUP(GRAPH(N,COUNT(N),GraphBody(ROWSET(LEFT),COUNTER)),Basepos);

		G := FETCH(Base.Bible,Key(Basepos in SET(g1,Basepos)),RIGHT.Basepos);
        
        RETURN TABLE(DEDUP(SORT(G,Book,Chapter,Verse),Book,Chapter,Verse),{Book,Chapter,Verse,Text});      
    END;
        
END;
