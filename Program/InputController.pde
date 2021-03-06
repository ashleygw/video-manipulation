/**
* The InputController manages changes in the state of the program.
* A single instance of it is contained in the Master Controller.
* It uses FFTController to manage sound responsive inputs.
*/
class InputController {
  
    //inputArray: state of inputs
    private InputObj inputArray[];
    //fftController: manages sound input
    private FFTController fftController;

    Map<Integer,Integer> INDEX_MAP;
    Map<String,Integer> SPECIAL_MAP;
    //soundFlag: takes sound input
    boolean soundFlag;
    //midiFlag: takes midi input
    boolean midiFlag;
    
    //for testing
    InputController(){}

    /**
    * Constructor initializes fields and constructs fftController
    * @param app : used by fftController to create Minim object
    * @param inputNum : the number of InputObj objects to create
    * @param isMidi : flag says if MidiPlayer is found
    * @param isSound : flag says if sound input decorating is on
    */
    InputController(PApplet app, boolean isMidi, boolean isSound) {

      INDEX_MAP = inputMap.buttonToArray();
      SPECIAL_MAP = inputMap.getSpecialButtons();

      int inputNum = INDEX_MAP.size();
      inputArray = new InputObj[inputNum];
      
      soundFlag = isSound;
      midiFlag = isMidi;

      //whether the input has a dead zone is specific to Midi
      boolean hasDeadZone = true; //configuring of dead zones should be refactored later
      HashMap<Integer,Float> updateMap = initMidiMap();
      
      //should be refactored to allow for non-Midi inputs
      if (soundFlag) {
        SoundDecorator soundInputArray[];
        SoundDecorator soundInput;
        soundInputArray = new SoundDecorator[inputNum];
        for (int i=0; i<inputNum; i++){
          MidiInput midiInputRef = new MidiInput(hasDeadZone);
          if (updateMap.containsKey(i)){
            midiInputRef.updateVal(updateMap.get(i));
          }
          soundInput = new SoundDecorator(midiInputRef);
          inputArray[i] = soundInput;
          soundInputArray[i] = soundInput;
        }
        fftController = new FFTController(soundInputArray,app);
      }
      else if (midiFlag) {
        for (int i=0; i<inputNum; i++){
          inputArray[i] = new MidiInput(hasDeadZone);
          if (updateMap.containsKey(i)){
            inputArray[i].updateVal(updateMap.get(i));
          }
        }
      }
    }

    /**
    * Returns hashmap with specific initial midi mapping values.
    */
    public HashMap<Integer,Float> initMidiMap(){
      HashMap<Integer,Float> updateMap = new HashMap<Integer,Float>();
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("Zoom")),63.5);
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("X_skew")),63.5);
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("Y_skew")),63.5);
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("X_Rotation")),63.5);
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("Y_Rotation")),63.5);
      updateMap.put(INDEX_MAP.get(SPECIAL_MAP.get("Fade")),127.0);
      return updateMap;
    }
    
    /**
    * Updates the state of program
    * @param number : which button/input is triggered
    * @param value : the value of that input
    */
    public void updateModel(int number, float value) {
      if (soundFlag) {
        fftController.updateModel(number, value);
      } else if (INDEX_MAP.get(number)!=null){
        inputArray[INDEX_MAP.get(number)].updateVal(value);
      }
    }
    
    /**
    * Returns the state of the program
    * @return inputArray : array of InputObj to use. Not reccomended to 
    *                       use outside of the input classes.
    */
    public InputObj[] fetchInputObjects() {
      /*
      if (soundFlag){
        return fftController.fetchInputs();
      } */
      return inputArray;
    }

    /*
     * Get the values form the InputObj's and put them into an ArrayList.
     * @return ArrayList representation of the state of inputArray.
     */
    public ArrayList<Float> fetchInputs() {
      ArrayList<Float> arr = new ArrayList<Float>();
      for (int i = 0; i < inputArray.length; i++) {
        arr.add((float)inputArray[i].getVal());
      }
      // System.out.println(arr.size());
      // System.out.println(inputArray.length);
      return arr;
    }

    /**
    * Updates sound listening
    */
    public void refresh(){
      if (soundFlag){
        fftController.refresh();
      }
    }
}
