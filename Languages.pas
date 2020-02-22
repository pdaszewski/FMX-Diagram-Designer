unit Languages;

interface

 uses
  System.SysUtils;

 procedure Set_dictionaries;
 procedure Set_language(language : String);

const
 max_languages = 2;
 max_entries = 20;

Var
 language_array : array[1..max_languages, 1..max_entries] of string;

 REMOVE_ASSOCIATION : string;
 ADD_ASSOCIATION : string;
 NEW_PROCESS : string;
 VERSION : string;
 CHANGE_THE_ASSOCIATION : string;
 PROCESS_NAME : string;
 DELETE_PROCESS : string;
 SAVE_PROCESS_DATA : string;
 REMOVE_ASSOCIATIONS : string;
 PROCESS_CONNECTIONS : string;
 CANCEL : string;

implementation

procedure Set_dictionaries;
Begin
 //EN dictionary
 language_array[1,1]  := 'remove association';
 language_array[1,2]  := 'add association';
 language_array[1,3]  := 'New process';
 language_array[1,4]  := 'version';
 language_array[1,5]  := 'change the association';
 language_array[1,6]  := 'Process Name';
 language_array[1,7]  := 'delete process';
 language_array[1,8]  := 'remove associations';
 language_array[1,9]  := 'save process data';
 language_array[1,10] := 'Process connections';
 language_array[1,11] := 'cancel';

 //PL dictionary
 language_array[2,1]  := 'usuñ powi¹zanie';
 language_array[2,2]  := 'dodaj powi¹zanie';
 language_array[2,3]  := 'Nowy proces';
 language_array[2,4]  := 'wersja';
 language_array[2,5]  := 'zmieñ powi¹zanie';
 language_array[2,6]  := 'Nazwa procesu';
 language_array[2,7]  := 'usuñ proces';
 language_array[2,8]  := 'usuñ powi¹zania';
 language_array[2,9]  := 'zapisz dane procesu';
 language_array[2,10] := 'Powi¹zania procesów';
 language_array[2,11] := 'anuluj';
End;

procedure Set_language(language : String);
var
  array_lang: Integer;
Begin
 language:=Trim(AnsiLowerCase(language));
 if language='en' then array_lang := 1;
 if language='pl' then array_lang := 2;

 REMOVE_ASSOCIATION     := language_array[array_lang,1];
 ADD_ASSOCIATION        := language_array[array_lang,2];
 NEW_PROCESS            := language_array[array_lang,3];
 VERSION                := language_array[array_lang,4];
 CHANGE_THE_ASSOCIATION := language_array[array_lang,5];
 PROCESS_NAME           := language_array[array_lang,6];
 DELETE_PROCESS         := language_array[array_lang,7];
 REMOVE_ASSOCIATIONS    := language_array[array_lang,8];
 SAVE_PROCESS_DATA      := language_array[array_lang,9];
 PROCESS_CONNECTIONS    := language_array[array_lang,10];
 CANCEL                 := language_array[array_lang,11];
End;

end.
