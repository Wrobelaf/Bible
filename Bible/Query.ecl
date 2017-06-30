IMPORT * from $.Inversion;
IMPORT * from Std.Str;

STRING  ToSearch  := ''    : STORED('SearchText');
BOOLEAN Near      := FALSE : STORED('Near');
BOOLEAN Old       := TRUE  : STORED('Old_Testaments');
BOOLEAN New       := TRUE  : STORED('New_Testaments');

s := Search(ToUpperCase(ToSearch),Near,Old,New);

COUNT(s);
OUTPUT(s)
