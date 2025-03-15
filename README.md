# Script di configurazione Linux
Lo scopo di questo script è automatizzare alcune operazioni comuni dopo
l'installazione di una distribuzione Linux, come:
- Configurare le repository
- Installare pacchetti
- Importare impostazioni dei software

## Requisiti
I seguenti software sono richiesti per eseguire con successo lo script:
- Utility di base (`grep`, `find`, `sed`...)
- `bash`
- `git`

## Utilizzo
1. Clonare questa repository
```bash
git clone 'https://github.com/lu-papagni/setup-script.git' -b main
```

2. Passare alla directory della repository
> [!CAUTION]
> Lo script è fatto in modo da essere eseguito dall'interno della repository.
> Tentare di eseguirlo da un'altra directory risulterà in un errore.

3. Fornire i permessi di esecuzione
```bash
chmod +x setup.sh
```

4. Avviare lo script come root
```bash
sudo -E ./setup.sh
```
> [!IMPORTANT]
> Il parametro `-E` è necessario per esportare le variabili d'ambiente dell'utente
> nel contesto root. Se si omette alcune operazioni potrebbero essere eseguite su
> directory sbagliate.

## Configurazione
Nella repository è presente una configurazione di default `default.cfg`, che
viene usato in automatico.
Se non dovesse essere presente verrà richiesto il percorso ad una configurazione valida.

Questi sono i parametri che è possibile specificare:
<table><thead>
  <tr>
    <th>Parametro</th>
    <th>Descrizione</th>
    <th>Default</th>
  </tr></thead>
<tbody>
  <tr>
    <td>ENABLE_UNSTABLE_MIRRORS</td>
    <td>Se disponibili, usa i repository di test/instabili.</td>
    <td>true</td>
  </tr>
  <tr>
    <td>INSTALL_PACKAGES</td>
    <td>Lista di nomi di pacchetti da installare.</td>
    <td>&lt;array di stringhe&gt;</td>
  </tr>
  <tr>
    <td>DOTFILES_REPO</td>
    <td>Nome della repository da cui scaricare le configurazioni.</td>
    <td>"lu-papagni/dots"</td>
  </tr>
  <tr>
    <td>DOTFILES_DIR</td>
    <td>Directory relativa alla home in cui salvare le configurazioni.</td>
    <td>".dotfiles"</td>
  </tr>
  <tr>
    <td>SYMLINK_BLACKLIST</td>
    <td>
      Percorso di un file contenente espressioni regolari usate per filtrare file e directory
      di cui verrà effettuato il collegamento simbolico.
    </td>
    <td>./symlink_ignore</td>
  </tr>
  <tr>
    <td>ENABLE_TMPFS</td>
    <td>Se la distribuzione non ha attivato tmpfs, come nel caso di WSL, abilita questa funzionalità.</td>
    <td>true</td>
  </tr>
  <tr>
    <td>TMPFS_MAX_SIZE</td>
    <td>
      Espresso in MiB. Se tmpfs viene configurato da questo script imposta questa dimensione come suo limite
      di capacità.
    </td>
    <td>256</td>
  </tr>
</tbody></table>
