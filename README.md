
# TYPING TUTOR - FINAL PROJECT

## Name: <ins> ZACHARY PADILLA </ins>

## Showcase:

![ezgif-4-bbeee3467d](https://github.com/barkeshli-CS066-classroom/99-final-project-typing-tutor-zachfpadilla/assets/73139549/28320ce9-4712-4fcf-b41b-a092743e009e)


<br><br>

## FULL PRESENTATION VIDEO:

https://github.com/barkeshli-CS066-classroom/99-final-project-typing-tutor-zachfpadilla/assets/73139549/ecd52265-f2d8-4817-971c-52f31e4e4aae




    
<br><br>

## LIST OF FUNCTIONS:
```
randomWord PROC 
    ; purpose: stores a random string from the word bank into edx
    ; args: eax, edx
    ; affect: no flags are affected
    ; return: edx contains the offset of a random word bank string
randomWord ENDP
```
```

wipeScreen PROC
    ; purpose: to clear out a smaller area of the terminal than ClrScr
    ; args: edx, ecx
    ; affect: no flags or registers affected
    ; return: the screen is cleared
wipeScreen ENDP

```
```

renderOverlay PROC
    ; purpose: to draw the killBar, accuracy, and WPM to the screen
    ; args: eax
    ; affect: no flags or registers affected
    ; return: the killBar, accuracy meter, and WPM meter are shown
renderOverlay ENDP

```
```

renderWord PROC
    ; purpose: to draw a string in edx at its specified place
    ; args: eax
    ; affect: no flags or registers affected
    ; return: the string in edx is drawn where its assigned
renderWord ENDP

```
```

fallWords PROC
    ; purpose: to re-render present words & drop them down
    ; args: edx, ecx
    ; affect: no flags or registers are affected
    ; return: all words are drawn & now a level lower
fallWords ENDP

```
```

tryForKey PROC
    ; purpose: to check for & process user keystrokes
    ; args: eax, ebx, ecx, edx, esi, edi
    ; affect: no flags/registers affected; invokes searchWordBank
    ; return: any user input has been checked for & processed
tryForKey ENDP

```
```

tryForKeyDict PROC
    ; purpose: a simplified input checker for the dictionary mode
    ; args: eax, ebx, ecx
    ; affect: no flags or registers affected
    ; return: any user input has been checked for & processed
tryForKeyDict ENDP

```
```

tryClearWord PROC
    ; purpose: to check for if a word should no longer be rendered
    ; args: edx, ecx, assumes currWBAddress points to a string
    ; affect: no flags or registers affected
    ; return: if completed, the string at currWBAddress is unrendered
tryClearWord ENDP

```
```

updateWPM PROC
    ; purpose: updates the user's typing accuracy value
    ; args: eax, ebx, edx, # of correct & total keystrokes
    ; affect: no flags or registers affected
    ; return: the accuracy number to be displayed is updated
updateWPM ENDP

```
```

searchWordBank PROC
    ; purpose: searches for the lowest word that matches the initial input
    ; args: ecx, edx, esi, edi, currWBAddress
    ; affect: no flags or registers affected
    ; return: currWBAddress now points to the optimal initial word
searchWordBank ENDP

```
```

fallingWordsDriver PROC
    ; purpose: to control the gameloop of the falling words mode
    ; args: eax, edx
    ; affect: no flags or registers affected
    ; return: the falling words mode will be played
fallingWordsDriver ENDP

```
```

dictionaryDriver PROC
    ; purpose: to control the gameloop of the dictionary mode
    ; args: eax, edx, esi
    ; affect: no flags or registers affected
    ; return: the dictionary mode will be played
dictionaryDriver ENDP

```
```

printWords PROC
    ; purpose: to print the word bank for use in dictionary mode
    ; args: eax, ebx, ecx, edx, esi
    ; affect: no flags or registers affected
    ; return: the contents of the word bank are printed to the screen
printWords ENDP

```
```

mainMenu PROC
    ; purpose: to prompt the user as to which gamemode to play
    ; args: eax, edx
    ; affect: no flags or registers affected
    ; return: the user can choose either dictionary or falling words
mainMenu ENDP

```


<br><br>
