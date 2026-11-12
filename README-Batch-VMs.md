# Batch Processing with SecGen

Generating multiple VMs in a batch is now possible through the use of batch_secgen, a ruby script which uses postgresql as a job queue to mass-create VMs with SecGen.

There are helper commands available to add jobs, list jobs in the table, remove jobs, and reset the status of jobs from 'running' or 'error' to 'todo'.  

When adding multiple jobs to the queue, it is possible to prefix the VM names with unique strings.
The example below demonstrates adding 3 copies of the flawed_fortress scenario, which results in the VM names being prefixed with 'tom_', 'cliffe_', and 'aimee_'.

```
ruby batch_secgen.rb add --instances tom,cliffe,aimee --- -s scenarios/ctf/flawed_fortress_1.xml r
```

## Initialise the Database

Install postgresql

```
sudo apt-get install postgresql

```

Add the database user role and give the user database superuser permissions.

```
sudo -u postgres createuser <username>
sudo -u postgres psql -c "CREATE ROLE <username> superuser;"
```

Create the database

```
sudo -u postgres createdb batch_secgen
```

Replace 'username' within the lib/batch/batch_secgen.sql dump with your database username on lines 131 and 141

```
...
128: REVOKE ALL ON TABLE queue FROM PUBLIC;
129: REVOKE ALL ON TABLE queue FROM postgres;
130: GRANT ALL ON TABLE queue TO postgres;
131: GRANT ALL ON TABLE queue TO username;  # << replace with database username
...
138: REVOKE ALL ON SEQUENCE queue_id_seq FROM PUBLIC;
139: REVOKE ALL ON SEQUENCE queue_id_seq FROM postgres;
140: GRANT ALL ON SEQUENCE queue_id_seq TO postgres;
141: GRANT SELECT,USAGE ON SEQUENCE queue_id_seq TO username; # << replace with database username
...
```

Import the modified SQL file

```
psql -U <username> batch_secgen < lib/batch/batch_secgen.sql
```

## Using secgen-batch.rb

COMMANDS:
add, a: Adds a job to the queue
start: Starts the service, works through the job queue
reset: Resets jobs in the table to 'todo' status based on option
delete: Delete job(s) from the queue table
list: Lists the current entries in the job queue

OPTIONS:
[add]
--instances [integer n]: Number of instances of the scenario to create with default project naming format
--instances [prefix,prefix, ...]: Alternatively supply a comma separated list of strings to prefix to project output
--randomise-ips [integer n ](optional): Randomises the IP range 10.X.X.0, unique for all instances,
                                        requires the number of unique static network tags in the scenario.xml
---: Delimiter, anything after this will be passed to secgen.rb as an argument.
Example: `ruby batch_secgen.rb add --instances here,are,some,prefixes --- -s scenarios/default_scenario.xml run`

[start]
--max_threads [integer n] (optional): Maximum number of worker threads, defaults to 1

[reset]
--running: Reset all 'running' jobs to 'todo'
--failed / --error: Reset all failed (i.e. status => 'error') jobs to 'todo'

[delete]
--id [integer n]: Delete the entry for a specific Job ID
--all: Delete all jobs from the queue table

[list]
--id [integer n] (optional): List the entry for a specific Job ID
--all: List all jobs in the queue table

[misc]
--help, -h: Shows this usage information


## Install the service to run batch-secgen in the background

Install the lib/batch/batch-secgen.service systemd service file.

```
sudo systemctl enable /absolute/path/to/SecGen/lib/batch/batch-secgen.service
service batch-secgen start
```

## Optional: keep the puppet scratch in RAM (`SECGEN_PUPPET_TMPFS`)

Generating a project copies the selected puppet modules into
`projects/<id>/puppet/` — one tree per system, hundreds of MB of small,
`fsync`-heavy files. On a slow or encrypted disk this is the heaviest local
I/O of a build, and several builds generating at once can stall the disk badly
enough to hang the host.

Set `SECGEN_PUPPET_TMPFS` to an existing directory on a tmpfs (RAM-backed)
filesystem and SecGen puts each project's `puppet/` tree there via a symlink,
while the project directory and everything worth keeping — the resolved
`scenario.xml`, `datastores` (spoiler passwords and flags), `flag_hints.xml`,
`Vagrantfile`, the `.vagrant` VM ids and `test_results/` — stay on the normal
disk. The puppet tree is reproducible from those records, so losing it on a
reboot or crash costs only a rebuild.

`/dev/shm` is a tmpfs on most systems and needs no root:

```
mkdir -p /dev/shm/secgen-puppet
export SECGEN_PUPPET_TMPFS=/dev/shm/secgen-puppet
```

`destroy-project` removes the RAM-backed tree along with the project. Budget
roughly 100 MB per system per build. The variable is optional: leave it unset
and `puppet/` is written to disk as before.
