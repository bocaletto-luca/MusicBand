# StudioBand

StudioBand è uno script Bash che ho sviluppato per gestire in modo semplice e professionale tutte le applicazioni audio e music production su Debian/Ubuntu. Con un’interfaccia testuale basata su whiptail, posso installare, rimuovere, visualizzare lo stato e lanciare i miei software preferiti in pochi secondi.

---

## Caratteristiche

- Catalogazione di DAW, synth, player e utility audio  
- Verifica immediata dello stato di installazione  
- Installazione e rimozione selettiva con scelta “keep config” o “purge”  
- Avvio multiplo di applicazioni direttamente dal menu  
- Possibilità di aggiungere applicazioni personalizzate (custom apps)  
- Configurazione persistente in `~/.studioband/`  

---

## Requisiti

- Sistema operativo Debian o Ubuntu  
- Bash (versione 4.x o superiore)  
- whiptail (`sudo apt-get install -y whiptail`)  
- Privilegi sudo  

---

## Installazione

1. Clono il repository sul mio sistema  
   ```bash
   git clone https://github.com/bocaletto-luca/StudioBand.git
   cd StudioBand
   ```

2. Rendo eseguibile lo script  
   ```bash
   chmod +x StudioBand.sh
   ```

3. Mi assicuro che whiptail sia installato  
   ```bash
   sudo apt-get update
   sudo apt-get install -y whiptail
   ```

4. Avvio StudioBand  
   ```bash
   ./StudioBand.sh
   ```

---

## Uso

All’avvio dello script compare un menu principale in cui posso scegliere:

1. **Installa / Rimuovi applicazioni** – Seleziono le app da gestire e decido se installare, rimuovere (mantendo i file di configurazione) o eseguire un purge completo.  
2. **Visualizza stato applicazioni** – Controllo in un colpo d’occhio quali software sono installati.  
3. **Lancia applicazioni** – Scelgo più programmi da avviare contemporaneamente.  
4. **Aggiungi custom app** – Inserisco nuove app con ID, nome, pacchetto APT e comando di lancio.  
5. **Info / Help** – Informazioni sulla versione e percorso dei file di configurazione.  

---

## Aggiunta di Custom App

Per includere un’applicazione non presente nella lista predefinita:

1. Seleziono “Aggiungi custom app” dal menu principale  
2. Inserisco un ID univoco (es. `mydrum`)  
3. Definisco il nome descrittivo  
4. Specifico il pacchetto APT da installare  
5. Indico il comando per avviare l’app  

Le informazioni vengono salvate in `~/.studioband/apps.custom` e lanciando di nuovo lo script l’app comparirà automaticamente nei menu.

---

## Personalizzazione

- Il file di configurazione principale si trova in `~/.studioband/`  
- Posso eseguire backup o ripristino semplice copiando questa cartella  
- Modificando il codice Bash (dichiarazioni `APP_NAME` e `APP_CMD`) aggiungo o rimuovo app “builtin”  

---

## Contribuire

Se vuoi migliorare StudioBand, sei il benvenuto! Ti basta:

1. Fork del progetto  
2. Creazione di un branch per la tua feature o correzione  
3. Apertura di una pull request descrivendo le modifiche  

Cerco di tenere lo script il più modulare e leggibile possibile, quindi ogni contributo è apprezzato.

---

## Licenza

Questo progetto è distribuito sotto licenza GPLv3. Per maggiori dettagli, consulta il file [LICENSE](LICENSE).
