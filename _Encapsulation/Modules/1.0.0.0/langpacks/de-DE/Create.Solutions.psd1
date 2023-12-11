﻿ConvertFrom-StringData -StringData @'
	# Translator                    = Yi

	IsCreate                        = Erstellen
	Solution                        = Lösung
	EnabledSoftwarePacker           = Fügen Sie eine Sammlung hinzu
	EnabledUnattend                 = Fügen Sie eine Vorantwort hinzu
	EnabledEnglish                  = Bereitstellungsmodul hinzufügen
	UnattendSelectVer               = Wählen Sie die Lösungssprache "Answer Answer" aus
	UnattendLangPack                = Wählen Sie das Sprachpaket "Lösung" aus
	UnattendSelectSingleInstl       = Mehrsprachig, optional bei Installation
	UnattendSelectMulti             = Mehrsprachig
	UnattendSelectDisk              = Wählen Sie die Lösung Autounattend.xml aus
	UnattendSelectSemi              = Halbautomatisch gültig für alle Installationsmethoden
	UnattendSelectUefi              = UEFI automatische Installation, muss angegeben werden
	UnattendSelectLegacy            = Legacy wird automatisch installiert, Sie müssen angeben
	NeedSpecified                   = Bitte wählen Sie aus, was angegeben werden soll:
	OOBESetupOS                     = Installationsschnittstelle
	OOBEProductKey                  = Produktschlüssel
	OOBEOSImage                     = Wählen Sie das zu installierende Betriebssystem aus
	OOBEEula                        = Akzeptieren Sie die Lizenzbedingungen
	OOBEDoNotServerManager          = Starten Sie Server Manager nicht automatisch bei der Anmeldung
	OOBEIE                          = Verstärkte Sicherheitskonfiguration für Internet Explorer
	OOBEIEAdmin                     = Schließen Sie "Administrator"
	OObeIEUser                      = "Benutzer" schließen

	OOBE_Init_User                  = Der erste Benutzer während des Unboxing-Erlebnisses
	OOBE_init_Create                = Erstellen Sie benutzerdefinierte Benutzer
	OOBE_init_Specified             = benannter Benutzer
	OOBE_Init_Autologin             = automatische Anmeldung

	InstlMode                       = Installationsmethode
	Business                        = Kommerzielle Version
	BusinessTips                    = Abhängig von EI.cfg, die automatische Installation muss die Indexnummer angeben.
	Consumer                        = Verbraucherausgabe
	ConsumerTips                    = Hängt nicht von EI.cfg ab, die Seriennummer muss für die automatische Installation angegeben werden, und die Indexnummer muss angegeben werden, wenn die Schnittstelle zur Versionsauswahl ausgesetzt wird.
	CreateUnattendISO               = [ISO]:\\Autounattend.xml
	CreateUnattendISOSources        = [ISO]:\\sources\\Unattend.xml
	CreateUnattendISOSourcesOEM     = [ISO]:\\sources\\$OEM$\\$$\\Panther\\unattend.xml
	CreateUnattendPanther           = [mounten nach]:\\Windows\\Panther\\unattend.xml

	VerifyName                      = Fügen Sie den Namen des Basisverzeichnisses der Systemfestplatte hinzu
	VerifyNameUse                   = Stellen Sie sicher, dass der Verzeichnisname nicht enthalten darf
	VerifyNameTips                  = Nur die Kombination aus englischen Buchstaben und Zahlen ist erlaubt und darf nicht enthalten: Leerzeichen, die Länge darf 260 Zeichen nicht überschreiten, \\ / : * ? & @ ! "" < > |
	VerifyNameSync                  = Legen Sie den Verzeichnisnamen als primären Benutzernamen fest
	VerifyNameSyncTips              = Administrator nicht mehr verwenden.
	ManualKey                       = Wählen Sie einen Produktschlüssel aus oder geben Sie ihn manuell ein
	ManualKeyTips                   = Geben Sie einen gültigen Produktschlüssel ein. Wenn der ausgewählte Bereich nicht verfügbar ist, wenden Sie sich bitte an Microsoft Official, um dies zu überprüfen.
	ManualKeyError                  = Der eingegebene Produktschlüssel ist ungültig.
	KMSLink1                        = KMS Client Setup Schlüssel
	KMSUnlock                       = Alle bekannten KMS Seriennummern anzeigen
	KMSSelect                       = Bitte wählen Sie eine VOL Seriennummer aus
	KMSKey                          = Seriennummer
	KMSKeySelect                    = Produktseriennummer ändern
	ClearOld                        = Alte Dateien bereinigen
	SolutionsSkip                   = Lösungserstellung überspringen
	SolutionsTo                     = 'Lösung' hinzufügen zu:
	SolutionsToMount                = Gemountet oder zur Warteschlange hinzugefügt
	SolutionsToError                = Einige Funktionen wurden deaktiviert, wenn Sie sie zwangsweise verwenden möchten, klicken Sie bitte auf die Schaltfläche "Entsperren".\n\n
	UnlockBoot                      = Freischalten
	SolutionsToSources              = Hauptverzeichnis, [ISO]:\\Sources\\$OEM$
	SolutionsScript                 = Wählen Sie die Version "Bereitstellungsmodul" aus
	SolutionsEngineRegionaUTF8      = Beta: Globale Sprachunterstützung mit Unicode UTF-8
	SolutionsEngineRegionaUTF8Tips  = Nach dem Öffnen scheint es, dass es neue Probleme verursachen kann. nicht vorgeschlagen.
	SolutionsEngineRegionaling      = Zum neuen Gebietsschema wechseln:
	SolutionsEngineRegionalingTips  = Ändern Sie das Systemgebietsschema, das sich auf alle Benutzerkonten auf dem Computer auswirkt.
	SolutionsEngineRegional         = Systemgebietsschema ändern
	SolutionsEngineRegionalTips     = Globaler Standard: {0}, geändert in: {1}
	SolutionsEngineCopyPublic       = Kopieren Sie öffentliches {0} in die Bereitstellung
	SolutionsEngineCopyOpen         = Durchsuchen Sie {0} öffentliche Speicherorte
	EnglineDoneReboot               = starte den Computer neu
	SolutionsSoftList               = Wählen Sie hinzugefügte Software aus
	SolutionsFontsList              = Wählen Sie eine hinzugefügte Schriftart aus
	SolutionsTipsArm64              = Das arm64 Paket wird bevorzugt, in der Reihenfolge: x64, x86.
	SolutionsTipsAMD64              = Bevorzugte x64 Pakete, in dieser Reihenfolge: x86.
	SolutionsTipsX86                = Fügen Sie nur x86 Pakete hinzu.
	SolutionsReport                 = Generieren Sie Berichte vor der Bereitstellung
	SolutionsDeployOfficeInstall    = Stellen Sie das Microsoft Office Installationspaket bereit
	SolutionsDeployOfficeChange     = Bereitstellungskonfiguration ändern
	SolutionsDeployOfficePre        = Vorinstallierte Paketversion
	SolutionsDeployOfficeNoSelect   = Office Vorinstallationspaket ist nicht ausgewählt.
	SolutionsDeployOfficeVersion    = {0} Ausführung
	SolutionsDeployOfficeOnly       = Behalten Sie das angegebene Sprachpaket bei
	SolutionsDeployOfficeSync       = Behalten Sie die Sprachsynchronisierung mit der Bereitstellungskonfiguration bei
	SolutionsDeployOfficeSyncTips   = Nach der Synchronisierung kann das Installationsskript die bevorzugte Sprache nicht ermitteln.
	DeploySyncMainLanguage          = Die Synchronisation ist konsistent mit der Hauptsprache
	SolutionsDeployOfficeTo         = Stellen Sie das Installationspaket bereit für
	SolutionsDeployOfficeToPublic   = öffentlicher Desktop
	DeployPackage                   = Stellen Sie ein benutzerdefiniertes Sammlungspaket bereit
	DeployPackageSelect             = Wählen Sie ein Pre Collection Paket
	DeployPackageTo                 = Stellen Sie das vorgefertigte Paket bereit
	DeployPackageToRoot             = Systemfestplatte: Systemfestplatte: \\Package
	DeployPackageToSolutions        = Home Verzeichnis der Lösung
	DeployTimeZone                  = Zeitzone
	DeployTimeZoneChange            = Zeitzone ändern
	DeployTimeZoneChangeTips        = Legen Sie die Standardzeitzone für die Vorabantwort nach Sprachzone fest.

	FirstExpProcess                 = Erstmalige Erfahrung während der Bereitstellung Voraussetzungen:
	FirstExpProcessTips             = Starten Sie den Computer neu, nachdem Sie die Voraussetzungen erfüllt haben, um das Problem zu lösen, dass ein Neustart erforderlich ist, um wirksam zu werden.
	FirstExpFinish                  = Erste Erfahrungen nach Erfüllung der Voraussetzungen
	FirstExpSyncMark                = Ermöglicht die vollständige Datenträgersuche und die Synchronisierung von Bereitstellungs-Tags
	FirstExpUpdate                  = Automatische Updates zulassen
	FirstExpDefender                = Home Verzeichnis zum Defend Ausschlussverzeichnis hinzufügen
	FirstExpSyncLabel               = Datenträgerbezeichnung des Systemlaufwerks: identisch mit dem Namen des Basisverzeichnisses
	MultipleLanguages               = Wenn Sie auf mehrere Sprachen stoßen:
	NetworkLocationWizard           = Netzwerkstandort Assistent
	PreAppxCleanup                  = Verhindern Sie, dass Appx Wartungsaufgaben bereinigt
	LanguageComponents              = Verhindern Sie die Bereinigung nicht verwendeter Feature-on-Demand-Sprachpakete
	PreventCleaningUnusedLP         = Verhindern Sie die Bereinigung nicht verwendeter Sprachpakete
	FirstExpContextCustomize        = Fügen Sie ein personalisiertes "Kontextmenü" hinzu
	FirstExpContextCustomizeShift   = Halten Sie die Umschalttaste gedrückt und klicken Sie mit der rechten Maustaste

	FirstExpFinishTips              = Nach Abschluss der Bereitstellung gibt es keine wichtigen Ereignisse, und es wird empfohlen, sie abzubrechen.
	FirstExpFinishPopup             = Die Hauptschnittstelle der Deployment Engine wird angezeigt
	FirstExpFinishOnDemand          = Erste Vorerfahrung wie geplant erlaubt
	SolutionsEngineRestricted       = Powershell Ausführungsrichtlinie wiederherstellen: Eingeschränkt
	EnglineDoneClearFull            = Löschen Sie die gesamte Lösung
	EnglineDoneClear                = Deployment Engine löschen, andere beibehalten

	Unattend_Auto_Fix_Next          = Automatische Korrektur, wenn die Voraussetzungen das nächste Mal ausgewählt werden
	Unattend_Auto_Fix               = Automatische Reparatur, wenn die Voraussetzungen nicht ausgewählt sind
	Unattend_Auto_Fix_Tips          = Wenn beim Hinzufügen einer Bereitstellungs-Engine der erste Ausführungsbefehl nicht ausgewählt wird, wird er automatisch repariert und ausgewählt: Powershell-Ausführungsstrategie: Führen Sie die Bereitstellungs-Engine ohne Einschränkungen aus.
	Unattend_Version_Tips           = Es kann so ausgewählt werden, dass nur ARM64, x64 und x86 unterstützt werden.
	First_Run_Commmand              = Befehle, die bei der ersten Bereitstellung ausgeführt werden sollen
	First_Run_Commmand_Setting      = Wählen Sie den auszuführenden Befehl aus
	Command_Not_Class               = Keine automatische Klassifizierung mehr beim Filtern
	Command_WinSetup                = Windows Installieren
	Command_WinPE                   = Windows PE
	Command_Tips                    = Bitte weisen Sie "Erste Ausführung angewendet" zu: Windows-Installation, Windows PE\n\nBeachten Sie, dass Sie beim Hinzufügen einer Bereitstellungs-Engine Folgendes überprüfen müssen: Powershell-Ausführungsrichtlinie: Eingeschränkt, Ausführung von Bereitstellungs-Engine-Skripts zulassen, wenn sie zum ersten Mal ausgeführt werden.
	Waring_Not_Select_Command       = Beim Hinzufügen einer Bereitstellungs-Engine wurde die Powershell-Ausführungsrichtlinie nicht ausgewählt: Keine Einschränkungen festlegen, die Ausführung von Bereitstellungs-Engine-Skripts zulassen, bitte auswählen und erneut versuchen oder auf "Schnellkorrektur nicht ausgewählt" klicken.
	Quic_Fix_Not_Select_Command     = Schnellkorrektur nicht ausgewählt

	PowerShell_Unrestricted         = Powershell Ausführungsrichtlinie: Keine Grenzen
	Allow_Running_Deploy_Engine     = Erlauben Sie die Ausführung von Deployment-Engine-Skripts
	Bypass_TPM                      = Umgehen Sie TPM Prüfungen während der Installation
'@