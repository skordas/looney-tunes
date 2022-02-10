 #!/bin/bash

report_file="$HOME/pomodoro_report.html"
projects_file="$(pwd)/projects"
log_directory="/home/skordas/.terminallo_pomodorro/"

# TODO remove that later
rm $report_file
# TODO remove that later



cat > $report_file <<- EOM
<!DOCTYPE html>
<html>
  <head>
    <title>Terminallo Pomodorro Raporrto!</title>
    <style>
      body {background-color: #fafafa; color: #4f4f4f; font-family: "JetBrains Mono", monospace, ui-monospace;}
      #header {background-color: #4f4f4f; color: #fafafa; text-align: center; font-size: 22px; padding-top: 25px; padding-bottom: 25px}
    </style>
  </head>
  <body class="main">
    <div id="header">Terminallo Pomodorro Raporrto!</div>
    <div class="report-body">
      <div class="segment>
        <div>
         
        </div>
      </div>
    </div>
  </body>
</html>
EOM

echo -e "Path to generated report: $report_file"
