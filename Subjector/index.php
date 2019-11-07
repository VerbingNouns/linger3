<?
  session_register('Record');
  $SubjectFile =    "subjects";
  $ExperimentFile = "experiments";
  $SessionFile =    "sessions";
?>
<html><head>
<title>The Subjector</title>
</head>
<center><h1>The Subjector</h1></center>

<?
$Fields = array("code", "last", "first", "email", "phone", "contact",
                "dob", "race");
$i = 0;
foreach ($Fields as $f)
  $FNum[$f] = $i++;

function error($msg) {
  echo "<font color=red>$msg</font><p>\n";
}

function done() {
  echo "<p><hr>";
  echo "<table width=100%><tr>";
  echo "<td>Written by <a href=mailto:dr+linger@tedlab.mit.edu>Doug Rohde</a>\n";
  echo "<td align=right><a href=http://tedlab.mit.edu/~dr/Linger/Subjector/readme.html>Instructions</a><br></table>";
  exit();
}

function val($f, $data) {
  global $FNum;
  $fnum = $FNum[$f];
  $val = trim($data[$fnum]);
  return trim($val, "}{");
}

function loadSessions($code) {
  global $Completed, $Available, $ExperimentFile, $SessionFile;
  $code = (int) $code;

  /* Load the sessions: */
  $Completed = array();
  $Available = array();
  $lines = file($SessionFile);
  foreach ($lines as $line) {
    $data = preg_split("/[\t ]+/", $line);
    if ((int) $data[0] == $code) {
      $Completed[$data[1]] = $data[2];
    }
  }  

  /* Load the experiments: */
  $lines = file($ExperimentFile);
  foreach ($lines as $line) {
    if ($line{0} == "#") continue;
    $conflicts = "";
    sscanf($line, "%s %d {%[^}]}", $exp, $time, $conflicts);
    
    if (!isset($Completed[$exp])) {
      $conflicts = preg_split("/[\t ]+/", $conflicts);
      $ok = 1;
      foreach ($Completed as $e => $junk) {
        foreach ($conflicts as $c) {
	  if (preg_match("/^" . $c . "$/", $e)) {
            $ok = 0;
	  }
        }
      }
      if ($ok) $Available[$exp] = $time;
    }
  }
}

function loadSubject($code) {
  global $Record, $FNum, $Fields, $SubjectFile;
  $code = (int) $code;
  $lines = file($SubjectFile);
  $fnum = $FNum["code"];
  foreach ($lines as $line) {
    $data = preg_split("/}* {/", $line);
    $c = (int) $data[$fnum];
    if ($c == $code) {
      foreach ($Fields as $f)
        $Record[$f] = val($f, $data);
      loadSessions($code);
      return;
    }
  }
  error("Failed to find subject number $code");
  done();
}

function match($f, $val, $pattern) {
  if ($f == "code") {
    return (int) $val == (int) $pattern;
  } else {
    return preg_match("#^" . $pattern . "#i", $val);
  }
}

function writeRecord($file) {
  global $_POST, $Record, $Fields;
  foreach ($Fields as $f) {
    if ($f == "code") {
      $_POST["code"] = sprintf("%04d", $_POST["code"]);
      fwrite($file, $_POST["code"]);
    }
    else fwrite($file, " {" . $_POST[$f] . "}");
    $Record[$f] = $_POST[$f];
  }
  fwrite($file, "\n");
}

/* Add a session: */
if (isset($_GET["addsession"])) {
  if ($_GET["code"] == "") {
    error("No subject given.");
    done();
  }
  $file = fopen($SessionFile, "a");
  fwrite($file, sprintf("%04d %-15s %s\n", $_GET["code"], 
    $_GET["addsession"], date("m/d/y")));
  fclose($file);
  loadSubject($_GET["code"]);

/* Remove a session: */
} else if (isset($_GET["remsession"])) {
  if ($_GET["code"] == "") {
    error("No subject given.");
    done();
  }
  $code  = (int) $_GET["code"];
  $exp   = $_GET["remsession"];
  $lines = file($SessionFile, "r");
  $file  = fopen($SessionFile, "w");
  foreach ($lines as $line) {
    $data = preg_split("/[\t ]+/", $line);
    if ((int) $data[0] != $code || strcmp($data[1], $exp))
      fwrite($file, $line);
  }
  fclose($file);
  loadSubject($_GET["code"]);

/* Load a particular subject: */
} else if (isset($_GET["code"])) {
  loadSubject($_GET["code"]);

/* Clear the record: */
} else if (isset($_POST[clear])) {
  foreach ($Fields as $f)
    $Record[$f] = "";

/* Submit a record: */
} else if (isset($_POST[submit])) {
  if ($_POST["first"] == "" || $_POST["last"] == "") {
    error("First and last names would be helpful.");
    foreach ($Fields as $f)
      $Record[$f] = $_POST[$f];
  } else { 
    $code = (int) $_POST[code];
    $fnum = $FNum["code"];
    $lines = file($SubjectFile);
    $file = fopen($SubjectFile, "w");
    $written = 0; $max = 0;
    foreach ($lines as $line) {
      $data = preg_split("/}* {/", $line);
      $c = (int) $data[$fnum];
      if ($c > $max) $max = $c;
      if ($c == $code) {
        if (!$written) writeRecord($file);
        $written = 1;
      } else fwrite($file, $line);
    }
    if (!$written) {
      if (trim($_POST["code"]) == "") $_POST["code"] = $max + 1;
      $code = $_POST["code"];
      writeRecord($file);
    }
    fclose($file);
    loadSessions($code);
  }

/* Search for subjects: */
} else if (isset($_POST[search])) {
  $keys = array();
  foreach ($Fields as $f) {
    $val = trim($_POST[$f]);
    if ($val != "")
      $keys[] = $f;
    $Record[$f] = $val;
  }
  if (count($keys) == 0) {
    error("Try filling in some fields before searching.");
  } else {
    $matches = array();
    $lines = file($SubjectFile);
    foreach ($lines as $line) {
      $data = preg_split("/}* {/", $line);
      $ok = 1;
      foreach ($keys as $f) {
        if (!match($f, val($f, $data), $Record[$f])) {
          $ok = 0;
	  break;
        }
      }
      if ($ok) {
        $code = $data[$FNum["code"]];
        $matches[] = $code;
        $label[$code] = $data[$FNum["first"]] . " " . $data[$FNum["last"]];
      }
    }
    $M = count($matches);
    if ($M == 0) {
      error("Sorry, no matches.");
    } else if ($M == 1) {
      loadSubject($matches[0]);
    } else {
      echo "Found $M matching records:<br><table>";
      foreach ($matches as $code) {
        echo "<tr><td><a href=index.php?code=$code>$code</a><td>$label[$code]\n";
      }
      echo "</table>";
      done();
    }
  }
}

?>



<form name=theform method=post action=index.php>
<center><table>
<!-- <tr><th colspan=5 align=center>Subject: -->
<?
  $Record[code] = trim($Record[code]);
  echo "<tr><td align=right>First:";
  echo "<td><input type=text size=20 name=first value=\"$Record[first]\">\n";
  echo "<td width=10>";
  echo "<td align=right>Last:";
  echo "<td><input type=text size=20 name=last value=\"$Record[last]\">\n";

  echo "<tr><td align=right>Email:";
  echo "<td><input type=text size=20 name=email value=\"$Record[email]\">\n";
  echo "<td width=10>";
  echo "<td align=right>Phone:";
  echo "<td><input type=text size=20 name=phone value=\"$Record[phone]\">\n";

  echo "<tr><td align=right>DOB:";
  echo "<td><input type=text size=20 name=dob value=\"$Record[dob]\">\n";
  echo "<td width=10>";
  echo "<td align=right>Race:";
  echo "<td><input type=text size=20 name=race value=\"$Record[race]\">\n";

  echo "<tr><td align=right>Contact:";
  echo "<td><input type=text size=20 name=contact value=\"$Record[contact]\">\n";
  echo "<td width=10>";
  echo "<td align=right>Code:";
  if ($Record[code] != "") {
    echo "<td><input type=text size=20 name=dcode value=\"$Record[code]\" disabled>\n";
    echo "<input type=hidden name=code value=\"$Record[code]\">\n";
  } else {
    echo "<td><input type=text size=20 name=code value=\"\">\n";
  }
?>
</table>
<input type=submit name=search value="Find Record">
<input type=submit name=clear  value="Clear Record">
<input type=submit name=submit value="<? if ($Record[code] == "") echo "Submit Record"; else echo "Update Record"; ?>">
</form></center>

<? if ($Record[code] != "" && count($Available) > 0) { ?>
<p><center><table>
<tr><th colspan=2 align=center>Available For:
<?
  if (preg_match("/DNR/", $Record["contact"])) {
    echo "<tr><th colspan=2 align=center><font color=red>Warning, DNR</font>\n";
  }

  foreach ($Available as $exp => $time) {
    echo "<tr><td width=120>$exp<td width=70>$time min.<td>";
    echo "<a href=index.php?code=$code&addsession=$exp>";
    echo "<img src=Images/add.gif border=0></a>\n";
  }
}
?>
</table></center>

<? if ($Record[code] != "" && count($Completed) > 0) { ?>
<p><center><table>
<tr><th colspan=3 align=center>Completed:
<?
  foreach ($Completed as $exp => $date) {
    echo "<tr><td width=120>$exp<td width=70>$date<td>";
    echo "<a href=index.php?code=$code&remsession=$exp>";
    echo "<img src=Images/remove.gif border=0></a>";
  }
?>
</table></center>
<?
}

done(); 
?>

<!--
Modes are:
basic/clear
search
submit
add experiment
remove experiment
-->