# FoodCoopNoord

Notities voor FCN (FoodCoopNoord) installatie van FS ten bate van DB migratie naar upstream versie 4.9.

Uitgaande van database behorende bij [foodcoop-adam](https://github.com/foodcoop-adam/foodsoft) `v3.4.0+adam+B`

- [FoodCoopNoord](#foodcoopnoord)
  - [Ubuntu](#ubuntu)
  - [MariaDB](#mariadb)
    - [Gebruikers](#gebruikers)
    - [FS development](#fs-development)
    - [Run FS](#run-fs)
  - [Upgrade DB](#upgrade-db)
    - [Restore](#restore)
      - [Pointers](#pointers)
    - [Preperation](#preperation)
    - [Migration](#migration)
    - [Post conversion](#post-conversion)
    - [Run](#run)
  - [Tips](#tips)
    - [Nuttige tools](#nuttige-tools)
    - [Dump](#dump)
    - [Admin](#admin)
    - [Collating](#collating)
    - [Decrypt database](#decrypt-database)
  - [Ontwikkelomgeving](#ontwikkelomgeving)
    - [TODO](#todo)
    - [Tests](#tests)

## Ubuntu

Ubuntu 24.04 LTS met laatste updates geïnstalleerd.

## MariaDB

Installeer. Ten tijde van schrijven `v10.11.8-MariaDB-0ubuntu.24.04.1`.

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

Let op! De basis is Ruby v2.3. Zie [upgrade issue](https://github.com/foodcoops/foodsoft/issues/1002) voor stand van zaken voor versie 3+.
Vele gems zijn ook (zeer) oud, dit kan hier en daar problemen geven bij het opzetten van de omgeving.

Volg [instructies](../doc/SETUP_DEVELOPMENT.md) van FS voor het opzetten van de ontwikkelomgeving.

Pas bij de stap met `rbenv exec gem install bundler` de gewenste (oude) versie toe `rbenv exec gem install bundler -v 2.4.22`. Dit omdat Ruby 2 EOL is en de huidige Bundler de nieuwere versie 3 verwacht.

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
   1. `EERST` deze stappen:
   2. Start een `TWEEDE` terminal
   3. Maak een kopie van `config/database.yml.MySQL_SAMPLE` en noem die `config\database.yml`

   Er zijn verschillende manieren om dit (meer of minder veilig) te configureren. Voor het gemak van ontwikkelen (en niet steeds bestanden te hoeven aanpassen) is gekozen voor een environment variable als definitie voor de DB gegevens.

   > Dit is _DUS_ niet een veilige productie oplossing ;-)

   Pas de sectie [development] aan

   ```yml
   database: foodsoft_development
   username: <% ENV['FOODSOFT_DB_USER] %>
   username: <% ENV['FOODSOFT_DB_PASSWORD] %>
   ```

   Definieer in het environment (`.bashrc` or `.zshrc` bv) en exporteer:

   ```bash
   export FOODSOFT_DB_USER=fooduser
   export FOODSOFT_DB_PASSWORD=foodpassword
   ```

   Open MariaDB

   ```bash
   mariadb
   ```

   Maak Foodsoft gebruiker aan EN maak een database aan zoals gedefinieerd in `config/database.yml`, i.e. `foodsoft_development`.
   Het lijkt erop dat het script deze database verwacht en niet aanmaakt als deze niet bestaat. Wat wel gebeurt voor de `test` omgeving. Lijkt een bug.

   ```sql
   CREATE DATABASE foodsoft_development
   CREATE USER 'fooduser'@'localhost' IDENTIFIED BY 'foodpassword';
   GRANT ALL PRIVILEGES ON foodsoft_development.* to 'fooduser'@'localhost';
   ```

   We houden alles verder standaard voor nu.

   > Ga nu terug naar de 1ste terminal met de wachtende `rbenv exec rails foodsoft:setup_development` - `FINISHED?` stap en bevestig `Y`.

6. config/storage
   1. Force rewrite
7. Mailcatcher
   1. `N`

Let op: `mailcatcher` heeft een specifieke versie van `thin` nodig die niet installeert via `bundler`. Zie [verder](#ontwikkelomgeving)

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

Start `foodsoft`.
Let op dat de eerder aangemaakte environment variabelen bekend zijn (start nieuwe terminal of `source environment`).

```bash
bundle exec rails s
```

Open [FS](http://localhost:3000)

Voor externe toegang:

```bash
bundle exec rails s --binding=0.0.0.0
```

Open FS van (http://[ipadres]:3000) lokaal of van een andere machine in je netwerk (in het geval van externe toegang).
Je moet nu een werkende, verder lege, FS hebben waarop in te loggen is met de standaard `admin@foo.test/secret` combinatie.

## Upgrade DB

Maak een nieuwe database, hier `foodsoft_adam` genoemd, in MariaDB.

### Restore

Restore een backup van de FoodCoopAdam installatie naar deze database.

```bash
mariadb foodsoft_adam < foodsoft_db.sql
```

#### Pointers

- Mariadb-dump seems to define constraints before the related table exists, this fails the restore.
  - Either swap the order in the dump file or 
  - create the table manually
- Older MariaDB and MySQL clients have problems with the `mariadb-dump` from the latest versions, see [here](https://mariadb.com/kb/en/mariadb-dump/)

### Preperation

Zet permissies voor de gebruiker om deze database te benaderen.

> Er zijn nu twee databases: een referentie `foodsoft_development` en `foodsoft_adam`.

- Run het FCN migratie script dat de database aanpast _voordat_ de Foodsoft migratie plaatsvindt. Dit zorgt ervoor dat de database in een staat is waarbij de FS migratie niet faalt, terwijl zoveel mogelijk data behouden blijft.

Zie de aanwijzingen in het [script](./MigratieFCN_naar_49.sql).

> Let op dat FS niet actief is, stop zonodig een eerder gestarte `exec rails s` instantie.

- Pas `config.database.yml` aan

```yml
database: foodsoft_adam
```

### Migration

- Run de FS migratie.

```bash
# env definitie uit database.yml: development of test
bin/rails db:migrate RAILS_ENV=development
```

### Post conversion

Some additional steps are needed to get the database, _after_ the FS migration,into the right state.

Zie de aanwijzingen in het [script](./MigratieFCN_naar_49_post.sql).

Controleer final resultaat: a dump file compare is the easiest for the schema.

### Run

Start FS en controleer de werking, zie [hier](#run-fs)

Als alles naar verwachting is verlopen zou er een [werkende FS v4.9](http://localhost:3000) moeten zijn met de gemigreerde data.
Inloggen met bekende gebruikers is nu mogelijk.

Dit is nog steeds op `development`! Dat betekent dat externe diensten, zoals emaill en Mollie, niet beschikbaar zijn.
Dat moet nog verder geconfigureerd worden.

## Tips

### Nuttige tools

- Visual file compare [Kompare](https://invent.kde.org/sdk/kompare)
- Database tool [DBeaver-CE](https:\\www.dbeaver.io)
- Encryptie [GPG](https://gpgtools.org/)

### Dump

Dump db referentie scheme

```bash
mariadb-dump --compact --add-drop-table --no-data --quick foodsoft_development > fs_db.sql
```

Dump FS Adam scheme

```bash
mariadb-dump --compact --add-drop-table --no-data --quick foodsoft_adam > fs_adam.sql
```

Gebruik een file compare programma om verschillen te vinden.

### Admin

Voor het toevoegen van de development admin aan de gemigreerde database, tbv testen van de migratie.

```sql
insert into foodsoft_adam.users (nick, password_hash, password_salt, first_name, last_name, email, created_on)
   select "fcn_admin", password_hash, password_salt, first_name, last_name, email, NOW() 
      from foodsoft_development.users b 
      where b.id = 1; 

-- Pas aan naar behoefte - ID's gebaseerd op FCN db
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 1); -- Lijstverwerkers / System admin
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 533); -- Uitgiftecoördinatoren
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 534); -- Bestelteam
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 536); -- Bestuur
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 801); -- Systeem
insert into foodsoft_adam.memberships (user_id, group_id) values (<nieuwe user id>, 820); -- Ledenadministratie
```

### Collating

Controlleer collating op afwijkende instellingen.

```sql
SELECT *
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'foodsoft_adam'
AND DATA_TYPE = 'varchar' or DATA_TYPE = 'text'
AND COLUMN_DEFAULT IS NOT NULL
AND
(
    CHARACTER_SET_NAME != 'utf8mb4'
    OR
    COLLATION_NAME != 'utf8mb4_general_ci'
);
```

### Decrypt database

Aangenomen dat het bronbestand met je public GPG key is versleuteld.

```bash
gpg --output foodsoft_db.sql.gz --decrypt [filename]
# Unpack the zip
gzip -d foodsoft_db.sql.gz
```

## Ontwikkelomgeving

In principe zorgt bovenstaande voor een werkende `v4.9.0`. Niet alle opties zullen echter werken.
Voor een `complete` ontwikkelomgeving is het nodig om alle gems te installeren.
Vanwege het feit dat nogal wat gems vrij oud zijn kan dit problemen geven.

Installeer de gewenste `thin` gem handmatig (via bundle faalt dit) en `mailcatcher` installeert dan ook niet.

```bash
gem install thin -v '1.6.2' -- --with-cflags="-Wno-error=implicit-function-declaration"
```

Voer de bundle install uit.

```bash
bundle install
```

### TODO

Voorzover bekend kunnen zowel [mailcatcher](https://rubygems.org/gems/mailcatcher) als [thin](https://rubygems.org/gems/thin) naar nieuwere versies getild worden. Waarbij de dependency met de EOL [skinny](https://rubygems.org/gems/skinny) verdwijnt.
Vermoedelijk wordt dit meegenomen met de geplande, en zeer noodzakelijk, upgrade naar Ruby 3x.

### Tests

```bash
bundle exec rake db:schema:load
bundle exec rake rspec-rerun:spec
```
