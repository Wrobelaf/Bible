IMPORT * FROM Std.Str;

EXPORT Clean(STRING s) := Filter(s,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ');