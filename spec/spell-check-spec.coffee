RootView = require 'root-view'

describe "Spell check", ->
  [editor] = []

  beforeEach ->
    window.rootView = new RootView
    rootView.open('sample.js')
    config.set('spell-check.grammars', [])
    window.loadPackage('spell-check')
    rootView.attachToDom()
    editor = rootView.getActiveEditor()

  it "decorates all misspelled words", ->
    editor.setText("This middle of thiss sentencts has issues.")
    config.set('spell-check.grammars', ['source.js'])

    waitsFor ->
      editor.find('.misspelling').length > 0

    runs ->
      expect(editor.find('.misspelling').length).toBe 2

      typo1StartPosition = editor.pixelPositionForBufferPosition([0, 15])
      typo1EndPosition = editor.pixelPositionForBufferPosition([0, 20])
      expect(editor.find('.misspelling:eq(0)').position()).toEqual typo1StartPosition
      expect(editor.find('.misspelling:eq(0)').width()).toBe typo1EndPosition.left - typo1StartPosition.left

      typo2StartPosition = editor.pixelPositionForBufferPosition([0, 21])
      typo2EndPosition = editor.pixelPositionForBufferPosition([0, 30])
      expect(editor.find('.misspelling:eq(1)').position()).toEqual typo2StartPosition
      expect(editor.find('.misspelling:eq(1)').width()).toBe typo2EndPosition.left - typo2StartPosition.left

  it "hides decorations when a misspelled word is edited", ->
    editor.setText('notaword')
    advanceClock(editor.getBuffer().stoppedChangingDelay)
    config.set('spell-check.grammars', ['source.js'])

    waitsFor ->
      editor.find('.misspelling').length > 0

    runs ->
      expect(editor.find('.misspelling').length).toBe 1
      editor.moveCursorToEndOfLine()
      editor.insertText('a')
      advanceClock(editor.getBuffer().stoppedChangingDelay)
      expect(editor.find('.misspelling')).toBeHidden()