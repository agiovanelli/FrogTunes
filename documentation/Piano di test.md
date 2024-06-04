# Introduzione 
In questo documento sono descritti l'ambito, l'approccio e il programma delle attività di testing che il team ha intenzione di svolgere lungo tutta la fase finale del progetto. Abbiamo scelto di attendere che il software fosse sviluppato almeno in parte; essendo infatti un progetto di piccole dimensioni risultava pressoche' inutile eseguire test nelle prime fasi (dove il software era composto da qualche semplice classe), come è invece usuale fare secondo le linee guida di standard sul testing (come IEEE 928).

Lo scopo principale di queste attività di testing è quello di verificare e validare il codice secondo i requisiti già classificati nella specifica dei requisiti. Viene inoltre testato il codice per identificare eventuali errori, bug e failure.
Per differenziare i risultati e quindi scoprire più difetti, è stata scelta una tecnica mista di testing che comprende principalmente quella manuale basata sui parametri sopra specificati.

Per questi motivi abbiamo scelto di utilizzare JUnit che consente di scrivere test automatizzati che possano essere eseguiti rapidamente e facilmente ogni volta che apporto modifiche al codice. 
Questo ci ha permesso di individuare errori o regressioni nel progetto in modo tempestivo, riducendo il rischio di introdurre problemi durante lo sviluppo.

# Funzionalità oggetto dei test
Il software è composto da due progetti principali: un server, contenente il codice per accedere e gestire il database, ed il client, a sua volta composto da una parte grafica e una parte che gestisce la comunicazione con il server.
Le attività di testing verranno eseguite separatamente su queste tre sezione, e in fase finale sul software completo.

# Test

