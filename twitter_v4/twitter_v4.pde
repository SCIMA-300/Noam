import java.util.*;
import twitter4j.*;
import twitter4j.conf.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import wordcram.*;


int size = 0;
int pageno = 1;
int currentTweet;
String user = "shyp";
//List<Status> tweets;
List<Status> tweets = new ArrayList<Status>();
String fileStore;
String timeString;
String wordsTable;


Twitter twitter;

void setup() {
  size(800, 600);
  timeString = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  println(timeString);
  fileStore = user + "_"+timeString + ".txt";
  wordsTable = user + "_"+timeString + "weighted.txt";
  println(fileStore);

  tConfigure();
  getNewTweets();
}


void draw() {
  fill(0, 40);
  rect(0, 0, width, height);




  Status status = tweets.get(currentTweet);
  println("current tweet: " + currentTweet);
  String str = status.getText();
  if (str.charAt(0) != '@') {
    appendTextToFile(fileStore, status.getText());
    fill(200);
    text(status.getText(), random(width-300), random(height-150), 300, 200);
    delay(20);
  }

    currentTweet = currentTweet + 1;

 
  if (currentTweet >= tweets.size()-1) {
    //currentTweet = 0;
    makeWordTable();
    println("Words Weighted and Saved");
    textAlign(CENTER);
    textSize(40);
    text("Weighted & done", width/2, height/2);
    noLoop();
  }

}

// GET NEW TWEETS ////////////////////////////////////////////

void getNewTweets() {
  while (true) {

    try {
      size = tweets.size(); 
      Paging page = new Paging(pageno, 100);
      tweets.addAll(twitter.getUserTimeline(user, page));
      println("GET - getting new tweets, page number " + pageno);
      pageno++;
      //if (tweets.size() == size || pageno == 5) //limit to 5 to save on API limit
      if (tweets.size() == size) // Unlimited - max amount of tweets (3200)
        break;
    }
    catch(TwitterException te) {
      System.out.println("Failed to search tweets: " + te.getMessage());
      System.exit(-1);
      te.printStackTrace();
    }
  }

  System.out.println("Total: "+tweets.size());
}


// CREATE AND APPEND TO TEXT FILE ////////////////////////////////////////////


void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
} 

// REFRESH THE DISPLAY ////////////////////////////////////////////

void keyPressed( ) {
  if ((key == 'Z') || (key == 'z')) {
    currentTweet = 0;
    loop();
  }
}

// WORDCRAM - MAKE WORD TABLE ////////////////////////////////////////////


void makeWordTable() {
  WordCram wordCram = new WordCram(this)
    .fromTextFile(fileStore)
      .sizedByRank(1, 30)
        .lowerCase()
// WORDS TO IGNORE ////////////////////////////////////////////
          .withStopWords("RT shyp radpad @radpad blueapron blueapron.com @blueapron @Chevron chevron washio washioapp @washioapp luxe @luxevalet luxevalet @google google span uber dropbox ideo @IDEO @ideo center API twitter name screen twitter-tweet video-youtube ul ve  xml:lang =  blockquote g-tweet re aligncenter height iframe layout h3 palm-one-whole hr rel com um alt 17th p1 s2 3.0 su-row que nossa unhcr 18pt alt lost div af font-weight style class airbnb width su-column-inner s1 em blank target strong href http de blog http://* nofollow post http://blog.airbnb.com br text-align src και li img amp   χουμε συγκινηθεί από τα μηνύματά σας από όλο τον κόσμο σχετικά με την προσφυγική και μεταναστευτική κρίση στην Αφρική, τη Μέση Ανατολή και την Ευρώπη. Αυτή είναι προφανώς μια εξαιρετικά πολύπλοκη και θλιβερή κατάσταση, και έχουμε εργαστεί σκληρά κατά τη διάρκεια των τελευταίων εβδομάδων για να καθορίσουμε πόσο εμείς &#8211; ως κοινότητα – μπορούμε να επιτύχουμε καλύτερα το όραμά μας στις δύσκολες αυτές στιγμές. Η προσέγγισή μας Στην Airbnb, παίρνουμε πολύ σοβαρά την εμπιστοσύνη που μας δείχνει η κοινότητά μας ως προς την ικανότητά μας να ενεργοποιούμε με δυναμικό και");  

  wordCram.getProgress();

  Word[] words  = wordCram.getWords();  
  Word[] skippedWords = wordCram.getSkippedWords();
  //println(skippedWords);  // Probably a long list!
  //  println("Placed " + (words.length - skippedWords.length) + 
  //    " words out of " + words.length);

  for (int i=0; i<words.length; i++) {
    Word word = words[i];

    // This will show either where the word was placed, or why it was skipped.
    //  println(word);
    appendTextToFile(wordsTable, word.toString());
  }
}