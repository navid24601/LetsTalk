# Let's Talk

Let's Talk is a conversation app for people sharing a device. Choose a set, pick a question or spin the wheel, and pass the device around. The goal is to help people connect and have fun through conversation.

This is a local prototype made with HTML, CSS, and JavaScript. It has no accounts, backend, database, or third-party dependencies. English speaking practice was mentioned as a possible future benefit; the app does not currently offer dedicated teaching, feedback, or assessment features. Some built-in sets contain IELTS speaking prompts, which are simply question content in this version.

## User manual

### Start the app

On Windows, double-click `start-app.bat`. Alternatively, open PowerShell in the project folder and run:

```powershell
py -m http.server 8000
```

Keep the terminal window open and visit [http://localhost:8000/](http://localhost:8000/) in your browser. Press **Ctrl+C** in the terminal to stop the server. On other systems, change into the project folder and run `python3 -m http.server 8000`.

Open the `localhost` address, rather than `index.html` directly. The app loads its built-in sets from a separate JSON file, and browsers may block that request when a page is opened as a local file.

**Troubleshooting**

- If port 8000 is already in use, stop the other server before starting this one. An older server may still be serving a different folder.
- If the browser shows a directory listing or a 404, check that you started the command in the project folder and that the browser is at `http://localhost:8000/`. Alternatively, use `start-app.bat` from the project folder.
- If the page says it cannot load the question set, check that the server is running and `sets.json` is present beside `index.html`, then refresh.
- If changes to the files do not appear, refresh the page. If necessary, use a hard refresh (Ctrl+F5 on Windows).

### Choose and discuss a question

1. Choose a set from **Question set**. The list shows its questions and their current states.
2. Select any question in the list to display it, or press **Spin the wheel** or the wheel itself. Both spin controls choose randomly from untouched questions. The wheel has one segment for each question in the active set and points to the selected question.
3. Discuss the question, then choose **Answered**, **Not interested**, or **Untouched**. You can change a question's state later. Selecting or spinning a question does not automatically mark it answered.
4. The explored count includes both answered and not-interested questions. Direct selection remains available for questions in any state. When none are untouched, spinning is disabled and the app offers a reset.
5. To start the set again, choose **Reset this set** and confirm. This returns every question in that set to untouched; other sets keep their progress.

The app works with a keyboard as well as touch or a mouse. The wheel is a button, and the interface follows the device's reduced-motion preference. The question list may scroll independently on larger screens.

### Import a question set

Choose **Manage sets**, then **Import a set**, and select a `.txt`, `.md`, or `.json` file. A successfully imported set becomes the active set and remains available in the same browser after refresh. Files must be no larger than 1 MB. Invalid files display an error in the management dialog.

For text and Markdown, the first nonempty line is the title, and each following nonempty line is one question. A Markdown heading marker on the title and numbered or bulleted markers on question lines are optional:

```md
# Around the table
1. What made you smile today?
2. Where would you go tomorrow?
- What would you like to learn?
```

For JSON, import **one object** with a title and an array of question strings:

```json
{
  "title": "Around the table",
  "questions": [
    "What made you smile today?",
    "Where would you go tomorrow?"
  ]
}
```

The title and every question must be nonempty; the title is limited to 200 characters. Each question must fit on one line, including in JSON. Text and Markdown blank lines are ignored, and leading and trailing whitespace is removed. A built-in `sets.json` file or other JSON array of sets is a different format and cannot be imported as one user-created set.

### Edit or delete an imported set

Open **Manage sets** and choose **Edit** or **Delete** beside an imported set. Built-in sets are listed there, but can only be changed in the project files.

When editing, put each question on its own line. Progress follows questions whose wording stays exactly the same, even if they are reordered. Changed or new questions start untouched. If a question occurs more than once, matching uses the previous order of the duplicates. Saving an edit to the active set clears the currently displayed question, but preserves the applicable progress. Deleting a set requires confirmation and removes that imported set and its progress from this browser.

### Where data is saved

Imported sets, their question states, built-in set progress, and the selected set are stored in this browser's local storage, separately by set. The currently displayed question is not restored after a refresh. Data is not synced between devices or browsers and may be lost if browser storage is cleared; private browsing may discard it when the session ends. There is currently no export or backup feature. If storage is unavailable or full, the app reports that it could not save.

The browser treats different origins separately: for example, `localhost` and `127.0.0.1`, or different port numbers, can have different saved data even on the same device. Use the same address to return to the same progress.

## Developer guide

### Project files

| File                                   | Purpose                                                                                       |
| -------------------------------------- | --------------------------------------------------------------------------------------------- |
| `index.html`                           | Page structure, controls, and dialogs.                                                        |
| `styles.css`                           | Visual design, responsive layout, focus styles, and reduced-motion rules.                     |
| `app.js`                               | Rendering, wheel selection, state changes, import/edit/delete, and local storage.             |
| `sets.json`                            | Array of built-in question sets loaded when the app starts.                                   |
| `start-app.bat`                        | Windows launcher for Python's local HTTP server.                                              |
| `testing_sample_files/`                | Sample files for trying imports.                                                              |
| `ielts-speaking-part-3-questions.json` | A separate JSON array of question sets; its contents are not loaded automatically by the app. |

The original built-in set came from the supplied 36-question file, with its numbering and labels removed. `sets.json` now also contains other conversation and IELTS prompt sets. The app displays the titles and questions in that file; it does not generate or teach their content.

### Add or change built-in sets

`sets.json` is a JSON array. Each object needs a unique, stable `id`, a nonempty `title`, and a nonempty array of question strings. The same validation rules for titles and questions apply as for imports. For example, add another object to the existing array:

```json
{
  "id": "dinner-table",
  "title": "Dinner table",
  "questions": [
    "What made you smile today?",
    "Where would you go tomorrow?"
  ]
}
```

Use valid JSON commas between objects, save the file as UTF-8, and refresh the app. Do not replace the existing array with the example if you want to keep the current sets. Avoid IDs beginning with `import-`, which the interface uses to identify imported sets.

**Progress caveat:** Built-in progress is keyed by set ID and question position, not by question text. Keep an existing ID and question order stable. If the number of questions changes, that set's saved states are reset to untouched when it is next loaded. If questions are reordered or replaced without changing the count, existing states stay at their old positions and may apply to different questions. Changing a set's ID makes it appear as a different set to storage.

### How the app fits together

On startup, `app.js` reads local storage, fetches and validates `sets.json`, then renders the active set. Built-in sets and locally imported sets are combined for display. `chooseUntouched` selects an eligible question independently of `drawWheel` and `animateWheel`, so another presentation can reuse the selection logic. The wheel uses a CSS conic gradient with one colored segment per question, then rotates to the chosen segment. Controls that could change the selection are disabled during a spin.

Question state and imported sets are saved under the legacy `good-questions-v1` local-storage key. The key is retained so existing saved progress remains available after the rename to Let's Talk. Imported-set edits match old and new questions by exact text to carry state forward. Built-in set states instead use the question positions described above. The app uses browser-native dialogs, file reading, and form controls; there is no build step.

## Design decisions and project log

This section records the main decisions visible in the requirements and implementation. Where the original discussion did not give a reason, the explanation describes the practical purpose of the choice rather than claiming a recorded motive.

- **Conversation first.** The original brief focused on connection and fun with people sitting together. The large question card, direct list, and status controls keep the shared conversation at the center; no dedicated English-learning features were included.
- **Local and lightweight.** The initial scope ruled out a backend, accounts, and a database. Plain HTML, CSS, JavaScript, and browser storage keep the prototype simple to run and extend, with the tradeoff that data is tied to a browser and is not backed up.
- **Questions as data.** Built-in sets live in a JSON array so new sets can be added without rewriting the interface. Imports use a smaller single-set format intended to be easy to create and validate.
- **Choice as well as chance.** Users can select any question directly or let the wheel choose an untouched one. The separate selection function leaves room for other random-selection animations later.
- **Three reversible states.** Untouched, answered, and not interested distinguish what remains eligible for a spin. Text and symbols accompany color, and users can return a question to untouched. Reset and delete use confirmation to reduce accidental loss.
- **Shared-device layout and accessibility.** Responsive layouts, labeled controls, keyboard operation, a live announcement, and reduced-motion support make the prototype usable across different devices and interaction preferences.
- **Layout revision.** The introductory section was removed in the later design update. Its instruction moved beneath “Let’s talk,” and set management moved beside the set picker so the conversation and set controls are closer together.
- **Wheel revision.** The initial decorative wheel used a fixed number of segments and a separate spin button. The later update made its segment count match the active set, aligned the pointer with the chosen question, and made the wheel itself a spin control.
- **Windows startup fix.** A trailing backslash in the original batch launcher's quoted directory caused Python to receive an incorrect path and return 404s. The launcher now appends `.` to the directory path; the manual also explains how to start the server from the project folder.

## Roadmap and future upgrades

These are possibilities mentioned in the original brief, not implemented features or a committed schedule:

- **PWA:** Extend the prototype into an installable progressive web app, including the manifest, service worker, and offline behavior that would be needed.
- **Android app:** Explore packaging or adapting the app for Android. The current version is a browser app, not an Android package.
- **English speaking practice:** Explore whether conversation could support speaking practice in a future version. The original brief explicitly excluded dedicated English-learning features from this prototype; their scope has not been decided.
- **Other random-selection animations:** Add alternative presentations using the existing separation between selection and the wheel animation. No other animation is currently available.

A backup/export mechanism and a safer way to migrate built-in progress when questions change would also address the current local-storage limitations; these are possible improvements, not previously requested features.
