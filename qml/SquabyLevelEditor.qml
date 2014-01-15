import QtQuick 1.1
import VPlay 1.0

LevelEditor {

  property bool __loadLevelForFirstTime: true

  Component.onCompleted: {
    console.debug("SquabyLevelEditor: entityManager:", entityManagerItem)
  }

  // NOTE: the trailing slash is important, otherwise the previous directory would be searched for!
  applicationJSONLevelsDirectory: "levels/jsonLevels/"

  qmlLevelList: [
    // the url is relative to the LevelLoader item
    // the levelId is needed, so it is possible to store the progress of the level, e.g. collected stars
    // NOTE: the url starts from the qml file where the LevelLoader is placed! so no levels/ is needed here
    {levelMetaData: {levelId: 1, levelName: "Level 1", levelBaseUrl: "01/Level01.qml" /* other metadata like description could be added here */}},
    {levelMetaData: {levelId: 2, levelName: "Level 2", levelBaseUrl: "02/Level02.qml"}},
    //{levelMetaData: {levelId: 3, levelName: "Level 3", levelBaseUrl: "levels/03/Level03.qml"}}
  ]
  levelBaseNameToUrlMap: {
    // the url is relative to the LevelLoader item
    // you can set the levelBaseName to any value you like, just make it unique in the map
    // you will probably define an own qml file that should trigger a LevelLoader.createNewLevel() when clicked
    "DynamicLevel01": {url: "empty/LevelEmpty.qml"},
//      "DynamicLevel02": {url: "DynamicLevel02.qml"},
  }

  // the LevelEditor must already have access to the LevelLoader when loadSingleLevel() is called!
  // thus the SquabyScene with the loader in it must be loaded already
  levelLoader: level ? level.levelLoader : {}

  // only store the obstacles, but NOT the PathEntity(PathSections and Waypoints) - these are stored as customData
  // the bed and closet will not be stored, because they have the preventFromRemovalFromEntitiyManager property set
  toStoreEntityTypes: ["obstacle"]

  onLoadLevelFinished: {
    console.debug("SquabyLevelEditor: finished loading single level with name", currentLevelName, "and id", currentLevelId)
    handleLoadLevelOrNewLevelFinished()
  }
  onNewLevelFinished: {
    console.debug("SquabyLevelEditor: finished creating a new level with name", currentLevelName, "and id", currentLevelId, ", createEmptyLevel was true:", createEmptyLevel)

    if(createEmptyLevel) {
      // if createEmptyLevel is true, we just created a new level from the LevelSelectionScene and thus want to switch to the game state
      handleLoadLevelOrNewLevelFinished()
    } else {
      // if createEmptyLevel is false, this means a new level got duplicated from the current one
      // however, saveLevel() also was called here and a messageBox is shown for it below, so we would not necessarily need to show another messagebox here
      nativeUtils.displayMessageBox("Successfully created a new level from the current one with name " + currentLevelName)
    }
  }

  function handleLoadLevelOrNewLevelFinished() {

    // also look at LevelSelectionScene::handleSingleLevelLoaded()


    // ---- FROM TwoPhaseLevelLoader ----

    // this was done in twoPhaseLevelLoader before, because of that loadLevelFinished() is called now
//    console.debug("TwoPhaseLevelLoader: setting levelSource to", toLoadLevelUrl)
//    // this is a costly operation, as the whole level is loaded!
//    level.levelSource = toLoadLevelUrl

    // dont enable pooling yet
    if(__loadLevelForFirstTime) {
      __loadLevelForFirstTime = false;
      console.debug("TwoPhaseLevelLoader: startGame() is called for the first time in this game, so precreate pooled entities, level:", level)
      var now = Date.now();
      // NOTE: this is a lenghty operation!
      level.preCreateEntitiesForPool()
      var dt = Date.now()-now;
      console.debug("SquabyLevelEditor: dt for preCreateEntitiesForPool:", dt)
    }

    // the SquabyScene has been loaded successfully here, otherwise the loading of level wouldnt have been started
    window.state = "game"

  }

  onRemoveLevelFinished: {
    nativeUtils.displayMessageBox("Successfully removed level with name " + removedLevelName)
  }
  onExportLevelAsFileFinished: {
    nativeUtils.displayMessageBox("Successfully exported level file with name " + currentLevelName)
  }
  onSaveLevelFinished: {
    nativeUtils.displayMessageBox("Successfully saved level with name " + currentLevelName)
  }
  onLevelError: {
    nativeUtils.displayMessageBox("Error at saving a level, content: " + JSON.stringify(errorData))
  }

/*
  these handlers are connected in the LevelSelectionScene
  onLoadAllLevelsFromStorageLocationFinished: {
    levelSelectionList.listModel = allLevelsData
    levelSelectionList.visible = true
  }
  // OLD: use the above call instead, which can be used if only a single level list selection is available (which is the most common use-case probably)
  // -> the changed-signals also are useful, e.g. when remove or save is selected, then the change is visible immediately in the levelList
  onAuthorGeneratedLevelsChanged: {
    console.debug("finished loading all authorGeneratedLevels, string data:", JSON.stringify(authorGeneratedLevels))
    levelSelectionList.listModel = authorGeneratedLevels
    levelSelectionList.visible = true
  }

  onApplicationQMLLevelsChanged: {
    console.debug("finished loading all applicationQMLLevels, string data:", JSON.stringify(applicationQMLLevels))
    levelSelectionList.listModel = applicationQMLLevels
    levelSelectionList.visible = true
  }
*/
}

