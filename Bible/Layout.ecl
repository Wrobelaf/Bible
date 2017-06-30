EXPORT Layout := MODULE

    EXPORT Testament := RECORD
        STRING1 Testament;
    END;
    
    EXPORT Book := RECORD
        STRING35 Book;
    END;
    
    EXPORT ChapterVerse := RECORD
       UNSIGNED1 Chapter;
       UNSIGNED1 Verse;
    END;
    
    EXPORT Layout_Raw_Book := RECORD    // Structure sprayed in.
       STRING600 Text;
    END;

    EXPORT Basic_Layout := RECORD       // Structure setup by 'DeclareData'
       Testament;                       // Not Boolean as we might add the 'Aprothria'
       Layout_Raw_Book;
    END;

    EXPORT Layout_Verse := RECORD       // Final 'base' structure upon which the 'Key' is built.
       Book;
       ChapterVerse;
       Basic_Layout;
    END;
    
END;
