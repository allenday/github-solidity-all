<?sol

/*
   COUNTER AND STATS
   Free program
   by D.G. Sureau
   ------------------------------
   requires the Scriptol compiler
   to produce a PHP page.

   www.scriptol.com
*/

` Put here the list of counters, one for each page
` No other change required in this file
` But the stats.sol one may be edited also

text  maincounter = "counter.val"
array counters = ("counter.val")


int total = 0
int countval = 0


` read a counter

text, int readcounter(text fname)
  text count
  text storeday = ""
  array line

 ` initialize the count of visitors for the day and total

  if file_exists(fname)  let line.load(fname)
  storeday = line[0].trim()    ` get the current date stored
  count    = line[1].trim()    ` get count of visitors of the day

return storeday, int(count)


void makestats()

   array days = ()
   array counts = ()
   int i

   ` reading two fields amoung five for now
   for i in 0 -- counters.size()
     days[i], counts[i] = readcounter(counters[i])
   /for

   file st                            ` add stats to the file
   st.open("stats.dat","a")
   flock(st, 6)
   st.write(days[0]);
   for i in 0 -- counters.size()
     st.write("," + counts[i])
   /for
   st.write("\n")
   flock(st, 7)
   st.close()

return


` update the counter for a page,  called from the page
` read the counter for this page
` increment count and test if best count
` save the counter with current date / count value and best count / date
` if today is not the date in the count file, reset counter,
` and make stats if main page of statflag is true

void update(text fname, boolean statflag = false)
  boolean changed = false
  int precount = 1
  countval = 1
  total = 1

  int bestval = 0                  ` best day count
  text bestday = date("d-m-Y")     ` the best date
  text today = date("d-M-Y")
  text storeday
  int  filein  = 0

  ` initialize the count of visitors for the day and total

  if file_exists(fname)     ` load the file of counts into an array
    array line
    line.load(fname)
    storeday = trim(line[0])            ` get the current date stored
    countval = intval(trim(line[1]))    ` get count of visitors of the day
    total    = intval(trim(line[2]))    ` get/incr count of total visitors
    bestday  = trim(line[3])            ` get the best date
    bestval  = intval(trim(line[4]))    ` get the count of best date
    countval + 1
    total + 1

    ` change best date if a better result reached

    if countval >= bestval
      bestday = today
      bestval = countval
    /if

    ` if day changed, a new count is restarted
    ` but only if main page, or if stat file updated
    ` by a hit of the main page

    if today <> storeday
      if (fname = maincounter) or statflag
        makeStats()    ` make stats before to save new data
        countval = 1
        storeday = today
      else
        text mainday
        array maindata
        maindata.load(maincounter)
        mainday = maindata[0].trim()
        ` if not main page, then
        ` count reset only if stat file has been created
        if today = mainday
           countval = 1
           storeday = today
        /if
      /if
    /if

  /if

 ` save the various data

 file fp
 fp.open(fname,"w")
 flock(fp, 6)
 fp.write("$storeday\n")      ` current date
 fp.write("$countval\n")      ` visitors of the day
 fp.write("$total\n")         ` total visitors
 fp.write("$bestday\n")       ` best date
 fp.write("$bestval\n")       ` visitors of the best day
 flock(fp, 7)
 fp.close()

return


` get a digit to disp the total counter

text digit(int num)
return substr("0000000000" + strval(total), -num, 1)

` get a digit to disp the counter of the current day

text dday(int num)
return substr("0000" + strval(countval), -num, 1)


?>

