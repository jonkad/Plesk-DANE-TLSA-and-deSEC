# Plesk DANE/TLSA deSEC DNS Update Script
This script helps update TLSA records on deSEC DNS service with Plesk.

## Instructions:
1. Edit Script:
- Change all variables marked within the script itself.
  
2. Save Script:
- Save the script file in a new directory, for example, /etc/dane/.

3. Make Script Executable:
- Run ``chmod +x update-script.sh``  to make the script executable.

4. Add Cron Job:
- Navigate to Plesk > Tools and Settings > Scheduled Tasks.
- Find the Let's Encrypt renewal task, usually named "Extension letsencrypt" and is located at "/opt/psa/admin/bin/php -dauto_prepend_file=sdk.php '/opt/psa/admin/plib/modules/letsencrypt/scripts/maintenance.php'". Note its execution time, for example, 03:05.
- Add a new task with the command ``/bin/bash /etc/dane/update-script.sh``, ensuring the execution time is after the Let's Encrypt renewal task. For instance, you can set it to run 5 minutes later, at 03:10.
- Ensure the script runs as root for necessary permissions.
