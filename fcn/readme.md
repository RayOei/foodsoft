# FCN- [FCN](#fcn)

Notities voor FCN (FoodCoopNoord) installatie van FS ten bate van DB migratie naar upstream versie.

- [FCN- FCN](#fcn--fcn)
  - [1. Ubuntu](#1-ubuntu)
  - [2. MariaDB](#2-mariadb)
    - [Gebruikers](#gebruikers)
    - [FS development](#fs-development)
    - [Run FS](#run-fs)
  - [3. Migratie](#3-migratie)
  - [4. Nuttige tools](#4-nuttige-tools)


##  1. Ubuntu

Ubuntu 24.04 LTS

##  2. MariaDB

Installeer. Ten tijde van schrijven `v10.11.8-MariaDB-0ubuntu.24.04.1`

```bash
sudo apt update
sudo apt install mariadb-server
sudo systemctl enable mariadb
sudo systemctl status mariadb

# Initialiseer
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mariadb

# Configureer
sudo mysql_secure_installation
```

Login als `root`

```bash
sudo mariadb
```

### Gebruikers

Voeg de admingebruiker toe en geef die alle rechten, inclusief het recht rechten te zetten!

```sql
CREATE USER 'your_admin_user'@'localhost';
GRANT ALL PRIVILEGES ON *.* to 'your_admin_user'@'localhost' WITH GRANT OPTION;
exit
```

Controleer of deze gebruiker `MariaDB` kan opstarten.

```bash
mariadb
```

### FS development

Volg [instructies](../doc/SETUP_DEVELOPMENT.md)

> Pas de stap met `rbenv exec gem install bundler` de versie `rbenv exec gem install bundler -v 2.4.22`. Dit omdat Ruby EOL is en Bundler een nieuwere versie verwacht.

!!! LET OP !!!

Bij de stap `rbenv exec rails foodsoft:setup_development` moeten een paar - niet duidelijk beschreven - tussenstappen voltooid worden.
Dit script verwacht `feitelijk` dat je configuraties aanpast `terwijl` je in het script zit. Dat is onduidelijk.

1. config/app_config.yml
   1. Force rewrite
2. config/environments/development.rb
   1. Force rewrite
3. config/database.yml
   1. Force rewrite
4. Kind database
   1. MySQL
5. Finished?
   1. EERST deze stappen:

Maak een kopie van `config/database.yml.MySQL_SAMPLE` en noem die `config\database.yml`

Er zijn verschillende manieren om dit (meer of minder veilig) te configureren.
Voor het gemak van ontwikkelen (en niet steeds bestanden te hoeven aanpassen) is gekozen voor een environment variable als definitie voor de DB gegevens.

> Dit is _DUS_ niet een veilige productie oplossing ;-)

Pas de sectie [development] aan

```yml
database: FOODSOFT_DB
username: <% ENV['FOODSOFT_DB_USER] %>
username: <% ENV['FOODSOFT_DB_PASSWORD] %>
```

Definieer in het environment (.bashrc or .zshrc bv) en exporteer:

```bash
export FOODSOFT_DB_USER=<whatever_user>
export FOODSOFT_DB_PASSWORD=<whatever_password>
```

```bash
mariadb
```

Maak Foodsoft gebruiker aan EN maak een database aan (zoals gedefinieerd in `config/database.yml`).
Het lijkt erop dat het script deze database verwacht en niet aanmaakt als deze niet bestaat. Wat wel gebeurt voor `test` omgeving. Lijkt een bug.

```sql
CREATE DATABASE foodsoft_development
CREATE USER 'fooduser'@'localhost' IDENTIFIED BY 'foodpassword';
GRANT ALL PRIVILEGES ON FOODSOFT_DB.* to 'fooduser'@'localhost';
```

We houden alles verder standaard voor nu.

> Ga nu verder met de `rbenv exec rails foodsoft:setup_development` stap en bevestig `Y`.

6. config/storage
   1. Force rewrite
7. Mailcatcher
   1. `N`

Het script zou nu zonder problemen een database moeten opbouwen. Als dat niet het geval is: controleer de environment variabelen.
> Er worden diverse waarschuwingen gegenereerd. Waarschijnlijk omdat de scripts niet meer volledig compatible zijn met de huidige MariaDB versie
Controleer met

```bash
mariadb
```

```sql
SHOW DATABASES
```

De lijst met databases moet nu ook `foodsoft_test` bevatten die door het script is aangemaakt.
Een `show tables` zou nu een gevulde `foodsoft_development` moeten tonen.

### Run FS

Start `foodsoft`

```bash
bundle exec rails s
```

Voor externe toegang:

```bash
bundle exec rails s --binding=0.0.0.0
```

##  3. Migratie

Restore een database van de FoodCoopAdam installie, hier `foodsoft_adam` genoemd.

Run het FCN migratie script dat de database aanpast voordat de Foodsoft migratie plaatsvindt. Dit zorgt ervoor dat de database in een staat is waarbij de FS migratie niet faalt, terwijl zoveel mogelijk data behouden blijft.

Zie de aanwijzingen in het [script](./MigratieFCN_naar_49.sql)

Run de FS migratie.

Controleer resultaat.

Start FS en controleer de werking.

Als alles naar verwachting is verlopen zou er een werkende FS v4.9 moeten zijn met de gemigreerde data.

Dit is nog steeds op `development`! Dat betekent dat externe diensten, zoals emaill en Mollie, niet beschikbaar zijn. 

Dat moet nog verder geconfigureerd worden.

##  4. Nuttige tools

- Visual file compare [Kompare](https://invent.kde.org/sdk/kompare)
- Database tool [DBeaver-CE](https:\\www.dbeaver.io)
