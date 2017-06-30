IMPORT $;

EXPORT DeclareData := MODULE

    base      := '~Bible::';
    SetBooks1 := 'genesis,exodus,levit,numbers,DEUTERONOMY';
    SetBooks2 := 'joshua,judges,Ruth,1samuel,2samuel,1kings,2kings,1CHRONICLES,2CHRONICLES,Ezra,Nehemiah,Esther,Job,Psalms,Proverbs,'
                +'Eccl,Song,Isaiah,Jeremiah,Lamentations,Ezekiel,Daniel,Hosea,Joel,Amos,'
                +'Obadiah,Jonah,Micah,Nahum,Habakkuk,Zeph,Haggai,Zech,Malachi';
    SetBooks3 := 'matthew,mark,luke,john,acts,Romans,1Corinthians,2Corinthians,Galatians,Ephesians,Philippians,Colossians,'
                +'1Thessalonians,2Thessalonians,1Timothy,2Timothy,Titus,Philemon,Hebrews,James,1Peter,2Peter,'
                +'1John,2John,3John,Jude,Revelation';

    Biblet1 := DATASET(base+'{'+SetBooks1+'}',$.Layout.Layout_Raw_Book,CSV(HEADING(2),SEPARATOR('')));
    Biblet2 := DATASET(base+'{'+SetBooks2+'}',$.Layout.Layout_Raw_Book,CSV(SEPARATOR('')));
    Biblet3 := DATASET(base+'{'+SetBooks3+'}',$.Layout.Layout_Raw_Book,CSV(SEPARATOR('')));

    BibleOld  := Biblet1+Biblet2;
    BibleNew  := Biblet3;

    RtestamentOld := RECORD
        STRING1 Testament := 'O';
        Text := BibleOld.Text;
    END;

    RtestamentNew := RECORD
        STRING1 Testament := 'N';
        Text := BibleNew.Text;
    END;

    EXPORT Bible := TABLE(BibleOld,RtestamentOld)+TABLE(BibleNew,RtestamentNew);
    EXPORT Base := '~Bible::Base';
    EXPORT Key  := '~Bible::Key';
 
END;
