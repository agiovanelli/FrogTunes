# Introduzione 
In questo documento sono descritti l'ambito, l'approccio e il programma delle attività di testing che il team ha intenzione di svolgere lungo tutta la fase finale del progetto. Abbiamo scelto di attendere che il software fosse sviluppato almeno in parte; essendo infatti un progetto di piccole dimensioni risultava pressoche' inutile eseguire test nelle prime fasi (dove il software era composto da qualche semplice classe), come è invece usuale fare secondo le linee guida di standard sul testing (come IEEE 928).

Lo scopo principale di queste attività di testing è quello di verificare e validare il codice secondo i requisiti già classificati nella specifica dei requisiti. Viene inoltre testato il codice per identificare eventuali errori, bug e failure.
Per differenziare i risultati e quindi scoprire più difetti, è stata scelta una tecnica mista di testing che comprende principalmente quella manuale basata sui parametri sopra specificati.

Per questi motivi abbiamo scelto di utilizzare JUnit che consente di scrivere test automatizzati che possano essere eseguiti rapidamente e facilmente ogni volta che apporto modifiche al codice. 
Questo ci ha permesso di individuare errori o regressioni nel progetto in modo tempestivo, riducendo il rischio di introdurre problemi durante lo sviluppo.

# Funzionalità oggetto dei test
Il software è composto da due progetti principali: un server, contenente il codice per accedere e gestire il database, ed il client, a sua volta composto da una parte grafica e una parte che gestisce la comunicazione con il server.
Le attività di testing verranno eseguite separatamente su queste tre sezione, e in fase finale sul software completo.

# Risorse 
Ogni componente del team eseguirà delle attività di testing confrontandosi con il resto del gruppo sul modus operandi e sulle tecniche da utilizzare, oltre ai dati da testare. Il piano di test è redatto da Fabio Izzo e Marco Zanda.

# Test
Test-Alessio-1
  Data: 09/12/2023
  Argomento: Test sulle classi
  Obiettivo: Controllare se le classi funzionano, generano codice univoco ID e non danno errori
  Cosa mi aspetto dal test: funzionamento
  Comandi eseguiti: "Utente u = new Utente("alessio", "ciaociao", "2");" esempio di una classe "utente" ma testato su tutte le classi con quindi la creazione di oggetti delle altre classi 
  Risultato del test: positivo

Test-Alessio-2
  Data: 23/12/2023
  Argomento: Test sulla comunicazione interfaccia registrazione
  Obiettivo: Controllare se facendo partire la schermata di registrazione tutto funziona o c’è qualche errore
  Cosa mi aspetto dal test: che mi faccia andare nella schermata di login
  Comandi eseguiti: test eseguito sulla sola interfaccia con inserimento dati
  Risultato del test: negativo, le credenziali non vengono salvate nel database e/o non vengono richiamate nel momento di login

Test-Biagio-1
  Data: 16/01/2024
  Argomento: Test sui file Jar
  Obiettivo: Capire se i file Jar presenti sono necessari
  Cosa mi aspetto dal test: Che l'eliminazione dei file non influisca il funzionamento del programma
  Comandi eseguiti: test eseguito eliminando i file e librerie per poi procedere all'avvio
  Risultato del test: positivo, i file sono superflui e sono stati eliminati

Test-Fabio-1
 Data: 21/02/2024
  Argomento: Test test verifica che l'istanza della classe Login_utente non sia nulla e che le dimensioni della finestra siano quelle attese
  Obiettivo: Controllare se le dimensioni dell'istanza classe Login_utente non sia nulla e le dimensioni della finestra siano quelle attese
  Cosa mi aspetto dal test: che l'istanza non sia nulla
  Comandi eseguiti: Test eseguito sulla schermata di login
  Risultato del test: positivo
 
Test-Marco-1
 Data: 24/01/2024-07/02/2024 
  Argomento: Test per verificare il corretto funzionamento della connessione socket tra client e server.
  Obiettivo: Verificare che le stringe inviate dal client siano ricevute dal server, e viceversa.
  Cosa mi aspetto dal test: Nel server appaia la stringa inviata dal client, nel client appaia la stringa inviata dal server
  Comandi eseguiti: Test eseguito con JUnit, utilizzando gli oggetti di java.net (in particolare Socket e ServSocket)
  Risultato del test: Negativo
  Problemi riscontrati: il server non riesce a restituire la stringa al client

Test-Marco-2
 Data: 08/02/2024 
  Argomento: Test 1
  Obiettivo: Test 1
  Cosa mi aspetto dal test: Test 1
  Comandi eseguiti: Test 1
  Risultato del test: Positivo

Test-Marco-3
 Data: 21/02/2024 
  Argomento: Trasferimento file da client a server
  Obiettivo: Trasferire un file audio dal client al server senza perdita di dati, e inserire le info associate nel database
  Cosa mi aspetto dal test: Nella cartella File del server voglio visualizzare il file inviato dal client, e nel database ne voglio visualizzare le specifiche
  Comandi eseguiti: Test eseguito con JUnit, utilizzando gli oggetti di java.net e java.io
  Risultato del test: Negativo 

Test-Marco-4
 Data: 28/02/2024 
  Argomento: Test 3
  Obiettivo: Test 3
  Cosa mi aspetto dal test: Test 3
  Comandi eseguiti: Test 3
  Risultato del test: Positivo 

Test-Fabio-2
 Data: 25/03/2024 
  Argomento: File audio
  Obiettivo: Salvataggio file mp3
  Cosa mi aspetto dal test: mi aspetto che il test verifichi se l'aggiunta di un file avviene con successo o meno.
  Comandi eseguiti: Test eseguito con JUnit
  Risultato del test: Positivo 

