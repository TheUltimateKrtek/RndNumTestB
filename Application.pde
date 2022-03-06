static class Application{
    static public class UpdateMessageCode{
        static final public int UNCHECKED = 0;
        static final public int CHECKING = 1;
        static final public int FAILED_CHECK = 2;
        static final public int VERSION_UP_TO_DATE = 3;
        static final public int VERSION_OUTDATED = 4;

        static final int getValue(int index){
            if(index < 0 || index > 4) return -1;
            return index;
        }
    }

    static private PApplet applet;
    static private int[] version;
    static protected int updateMessageCode = UpdateMessageCode.UNCHECKED;
    static public boolean showUpdateMessage = true;
    static private int[] lastestVersion;
    static private JSONObject settingsJson;
    static private ApplicationVersionFetcherThread applicationVersionFetcherThread;

    static public void init(PApplet applet){
        Application.applet = applet;
        Application.loadSettings();
        Application.compareVersion();
    }

    static public void loadSettings(){
        Application.settingsJson = applet.parseJSONObject(applet.join(applet.loadStrings(applet.dataPath("settings.json")), "\n"));

        JSONArray versionJson = Application.settingsJson.getJSONArray("version");
        Application.version = new int[versionJson.size()];
        for(int i = 0; i < Application.version.length; i ++) Application.version[i] = versionJson.getInt(i);
        Application.lastestVersion = new int[Application.version.length];
        for(int i = 0; i < Application.version.length; i ++) Application.lastestVersion[i] = Application.version[i];

        String fontPath = Application.settingsJson.getString("fontPath");
        Global.setFont(fontPath);
        
        int lastResolution = Application.settingsJson.getInt("lastResolution");
        Global.outputScale = lastResolution;
    }
    static public void saveSettings(){
        Application.settingsJson.setInt("lastResolution", Global.outputScale);
        Application.settingsJson.setString("fontPath", Global.fontPath);
        applet.saveJSONObject(Application.settingsJson, applet.dataPath("settings.json"));
    }
    static public void compareVersion(){
        Application.applicationVersionFetcherThread = new ApplicationVersionFetcherThread(Application.applet);
        Application.applicationVersionFetcherThread.start();
    }
    static public int getUpdateMessageCode(){
        return Application.updateMessageCode;
    }
    static public int[] getCurrentVersion(){
        return new int[]{Application.version[0], Application.version[1], Application.version[2]};
    }
    static public int[] getLastestVersion(){
        return new int[]{Application.lastestVersion[0], Application.lastestVersion[1], Application.lastestVersion[2]};
    }
    static protected void setUpdateMessage(int index){
        Application.updateMessageCode = index;
        Application.showUpdateMessage = true;
    }

    static private class ApplicationVersionFetcherThread extends Thread{
        private PApplet applet;

        public ApplicationVersionFetcherThread(PApplet applet){
            this.applet = applet;
        }

        void run(){
            try{
                Application.updateMessageCode = UpdateMessageCode.CHECKING;
                String url = "https://api.github.com/repos/TheUltimateKrtek/RndNumTestB/releases/latest";
                JSONObject json = this.applet.loadJSONObject(url);
                String versionName = json.getString("name");
                int firstDigit = -1;
                int lastDigit = -1;
                char[] chars = versionName.toCharArray();
                for(int i = 0; i < chars.length; i ++){
                    if(Character.isDigit(chars[i]) || chars[i] == '.'){
                        if(firstDigit == -1) firstDigit = i;
                        lastDigit = i;
                    }
                    else if(firstDigit != -1) break;
                }

                versionName = versionName.substring(firstDigit, lastDigit + 1);
                StringList sl = new StringList();
                String current = "";
                for(int i = 0; i < versionName.length(); i ++){
                    char c = versionName.charAt(i);
                    if(c == '.'){
                        if(current.length() != 0){
                            sl.append(current);
                            current = "";
                        }
                    }
                    else{
                        current += c;
                    }
                }
                sl.append(current);

                int[] lastestVersion = new int[sl.size()];
                for(int i = 0; i < sl.size(); i ++) lastestVersion[i] = Integer.parseInt(sl.get(i));
                
                boolean decided = false;
                for(int i = 0; i < Math.min(lastestVersion.length, Application.version.length); i ++){
                    if(lastestVersion[i] > Application.version[i]){
                        Application.setUpdateMessage(Application.UpdateMessageCode.VERSION_OUTDATED);
                        decided = true;
                        break;
                    }
                    if(lastestVersion[i] < Application.version[i]) throw new Exception("Exception 1");
                }

                if(!decided){
                    if(lastestVersion.length > Application.version.length) Application.setUpdateMessage(Application.UpdateMessageCode.VERSION_OUTDATED);
                    else if(lastestVersion.length < Application.version.length) throw new Exception("Exception 2");
                    else Application.setUpdateMessage(Application.UpdateMessageCode.VERSION_UP_TO_DATE);
                }

                Application.lastestVersion = lastestVersion;
            }
            catch(Exception e){
                e.printStackTrace();
                Application.lastestVersion = new int[]{-1};
                Application.setUpdateMessage(Application.UpdateMessageCode.FAILED_CHECK);
            }
        }
    }
}