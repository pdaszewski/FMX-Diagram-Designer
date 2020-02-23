unit Languages;

interface

 uses
  System.SysUtils;

 procedure Set_dictionaries;
 procedure Set_language(language : String);

const
 max_languages = 4;
 max_entries = 18;

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
 APPLICATION_MENU : string;
 NEW_DIAGRAM : string;
 FULL_SCREEN : string;
 LOAD_PROJECT : string;
 SAVE_PROJECT : string;
 CLOSE_THE_MENU : string;
 INTERFACE_LANGUAGE : string;

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
 language_array[1,12] := 'Application menu';
 language_array[1,13] := 'new diagram';
 language_array[1,14] := 'full screen';
 language_array[1,15] := 'load project';
 language_array[1,16] := 'save project';
 language_array[1,17] := 'close the menu';
 language_array[1,18] := 'interface language';

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
 language_array[2,12] := 'Menu g³ówne aplikacji';
 language_array[2,13] := 'nowy diagram';
 language_array[2,14] := 'pe³en ekran';
 language_array[2,15] := 'wczytaj projekt';
 language_array[2,16] := 'zapisz projekt';
 language_array[2,17] := 'zamknij menu g³ówne';
 language_array[2,18] := 'jêzyk interfejsu aplikacji';

 //DE dictionary
 language_array[3,1]  := 'assoziation entfernen';
 language_array[3,2]  := 'assoziation hinzufügen';
 language_array[3,3]  := 'Neuer Prozess';
 language_array[3,4]  := 'ausführung';
 language_array[3,5]  := 'Ändern Sie die Zuordnung';
 language_array[3,6]  := 'Vorgangsname';
 language_array[3,7]  := 'löschvorgang';
 language_array[3,8]  := 'assoziationen entfernen';
 language_array[3,9]  := 'prozessdaten speichern';
 language_array[3,10] := 'verbindungen verarbeiten';
 language_array[3,11] := 'stornieren';
 language_array[3,12] := 'anwendungsmenü';
 language_array[3,13] := 'neues Diagramm';
 language_array[3,14] := 'ganzer Bildschirm';
 language_array[3,15] := 'projekt laden';
 language_array[3,16] := 'projekt speichern';
 language_array[3,17] := 'schließen Sie das Menü';
 language_array[3,18] := 'schnittstellensprache';

 //FR dictionary
 language_array[4,1]  := 'supprimer l''association';
 language_array[4,2]  := 'ajouter une association';
 language_array[4,3]  := 'Nouveau processus';
 language_array[4,4]  := 'version';
 language_array[4,5]  := 'changer l''association';
 language_array[4,6]  := 'Nom du processus';
 language_array[4,7]  := 'processus de suppression';
 language_array[4,8]  := 'supprimer les associations';
 language_array[4,9]  := 'enregistrer les données de processus';
 language_array[4,10] := 'Connexions de processus';
 language_array[4,11] := 'Annuler';
 language_array[4,12] := 'Menu d''application';
 language_array[4,13] := 'nouveau diagramme';
 language_array[4,14] := 'plein écran';
 language_array[4,15] := 'charger le projet';
 language_array[4,16] := 'sauvegarder le projet';
 language_array[4,17] := 'fermer le menu';
 language_array[4,18] := 'langue de l''interface';
End;

procedure Set_language(language : String);
var
  array_lang: Integer;
Begin
 language:=Trim(AnsiLowerCase(language));
 if language='en' then array_lang := 1;
 if language='pl' then array_lang := 2;
 if language='de' then array_lang := 3;
 if language='fr' then array_lang := 4;

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
 APPLICATION_MENU       := language_array[array_lang,12];
 NEW_DIAGRAM            := language_array[array_lang,13];
 FULL_SCREEN            := language_array[array_lang,14];
 LOAD_PROJECT           := language_array[array_lang,15];
 SAVE_PROJECT           := language_array[array_lang,16];
 CLOSE_THE_MENU         := language_array[array_lang,17];
 INTERFACE_LANGUAGE     := language_array[array_lang,18];
End;

end.
