
 class GetTimeAgo {

     static  int secondMillis = 1000;
     static final int minuteMILLIS = 60 * secondMillis;
     static final int hourMILLIS = 60 * minuteMILLIS;
     static final int dayMILLIS = 24 * hourMILLIS;


     static  getTimeAgo(time) {
        if (time < 100000000000000) {
            // if timestamp given in seconds, convert to millis
            time *= 1000;
        }

        var now = DateTime.now().millisecondsSinceEpoch;
        if (time > now || time <= 0) {
            return null;
        }

        var diff = now - time;
        if (diff < minuteMILLIS) {
            return "just now";
        } else if (diff < 2 * minuteMILLIS) {
            return "a minute ago";
        } else if (diff < 50 * minuteMILLIS) {
            return "$diff '/' $minuteMILLIS +  minutes ago";
        } else if (diff < 90 * minuteMILLIS) {
            return "an hour ago";
        } else if (diff < 24 * hourMILLIS) {
            return "$diff / $hourMILLIS +  hours ago";
        } else if (diff < 48 * hourMILLIS) {
            return "yesterday";
        } else {
            return "$diff / $dayMILLIS +  days ago";
        }
    }

}
