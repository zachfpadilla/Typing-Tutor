INCLUDE Irvine32.inc
INCLUDE Macros.inc



maxCols EQU 80
maxRows EQU 30
maxStringLength EQU 13



gameWord STRUCT
	wordString BYTE maxStringLength DUP(0)				; wordString must be 12 chars or less
	states BYTE 0										; ex) bit 0 = isVisible
	xPos BYTE 0
	yPos BYTE 0
gameWord ENDS



.data
	currWBAddress DWORD -1
	charBuffer BYTE maxStringLength DUP(0)
	cBIndex DWORD 0

	currSec DWORD ?
	maxWordsInGame DWORD -1
	gameOver BYTE 0

	accuracy DWORD 0
	numCorrectKeys DWORD 0
	numTotalKeys DWORD 0
	WPM DWORD 0
	numCorrectWords DWORD 0
	elapsedTime DWORD 0
	
	killBar BYTE maxCols DUP('-'), 0

	wordBank GAMEWORD <"awesome">, <"cool">, <"loser">, <"skibidi">, <"goon">, <"banana">,
					  <"bard">, <"orange">, <"apple">, <"banana">, <"alamode">, <"chicken">,
					  <"lard">, <"orangutan">, <"noble">, <"bruh">, <"typing">, <"game">,
					  <"cs66">, <"final">, <"project">, <"yippee">, <"awesome">, <"cool">,
					  <"loser">, <"skibidi">, <"goon">, <"noble">, <"bard">, <"orange">,
					  <"apple">, <"orangutan">, <>



.code
randomWord PROC uses EAX								;stores a random gameWord address from wordBank into EDX
	mov EAX, LENGTHOF wordBank
	call RandomRange
	shl EAX, 4

	mov EDX, OFFSET wordBank
	add EDX, EAX

	ret
randomWord ENDP



wipeScreen PROC uses EDX ECX
	mGotoxy 0, 0
	mWriteSpace maxCols
	mov ECX, maxRows - 1
	
	rowLoop:
		mGotoxy 0, CL
		mWriteSpace maxCols
	loop rowLoop
	ret
wipeScreen ENDP



renderOverlay PROC uses EAX
	mGotoxy 0, 0
	mWrite "Accuracy: "
	mov EAX, accuracy
	call WriteInt
	mWrite "%  "

	mGotoxy 20, 0
	mWrite "WPM: "
	mov EAX, WPM
	call WriteInt

	mGotoxy 0, maxRows - 1
	mWriteString OFFSET killBar

	ret
renderOverlay ENDP



renderWord PROC uses EAX
	mov EAX, EDX
	mov DL, (GAMEWORD PTR [EAX]).xPos
	mov DH, (GAMEWORD PTR [EAX]).yPos
	
	call Gotoxy
	mov EDX, EAX
	call WriteString
	ret
renderWord ENDP



spawnNewWord PROC uses EAX ECX									;puts a gameWord onto the screen (logic-wise)
	mov EAX, maxCols - 13
	call RandomRange
	call randomWord
	
	isVisibleLoop:
		call randomWord
		test (GAMEWORD PTR [EDX]).states, 10000000b
	loopnz isVisibleLoop
	cmp BYTE PTR [EDX], 0
	je isVisibleLoop
		
	or (GAMEWORD PTR [EDX]).states, 10000000b
	mov (GAMEWORD PTR [EDX]).xPos, AL
	mov (GAMEWORD PTR [EDX]).yPos, 1
	ret
spawnNewWord ENDP



fallWords PROC uses EDX ECX
	mov EDX, OFFSET wordBank + SIZEOF wordBank - TYPE wordBank
	mov ECX, LENGTHOF wordBank

	fallVisibleWords:
		test (GAMEWORD PTR [EDX]).states, 10000000b

		jz isNotVisible
			inc (GAMEWORD PTR [EDX]).yPos
			cmp (GAMEWORD PTR [EDX]).yPos, maxRows - 1
			jne gameNotOver
				mov gameOver, 1
			gameNotOver:
			call renderWord
		isNotVisible:

		sub EDX, TYPE wordBank
	loop fallVisibleWords
	
	call renderCurrWord
	ret
fallWords ENDP



tryForKey PROC uses EAX EBX ECX EDX ESI EDI
	mov EAX, 10
	call Delay	
	call ReadKey

	mov EBX, cBIndex
	mov ECX, currWBAddress

	jz noKey
		.IF ECX == -1
			call searchWordBank
			mov ECX, currWBAddress
		.ENDIF
		.IF ECX == -1
			ret
		.ELSE
			mov charBuffer[EBX], AL
			inc cBIndex
			inc numCorrectKeys
			inc numTotalKeys
			call renderCurrWord
			
			mov BL, (GAMEWORD PTR [ECX]).yPos
			call tryClearWord
			test (GAMEWORD PTR [ECX]).states, 10000000b
			jnz noKey
				mGotoxy 0, BL
				mWriteSpace maxCols
		.ENDIF
	noKey:
	ret
tryForKey ENDP



tryForKeyDict PROC uses EAX EBX EDX
	mov EAX, 10
	call Delay	
	call ReadKey

	mov EBX, cBIndex

	jz noKey
		mov charBuffer[EBX], AL
		inc cBIndex
		inc numCorrectKeys
		inc numTotalKeys
		call renderCurrWord
		call tryClearWord
	noKey:
	ret
tryForKeyDict ENDP



tryClearWord PROC uses EAX ECX EDX
	mov ECX, 0
	mov EDX, currWBAddress
	call StrLength
	cmp EAX, cBIndex
	jnz notCleared
		
		and (GAMEWORD PTR [EDX]).states, 01111111b
		mov (GAMEWORD PTR [EDX]).yPos, 1
		mov currWBAddress, -1
		.WHILE charBuffer[ECX] != 0
			mov charBuffer[ECX], 0
			inc ECX
		.ENDW
		mov cBIndex, 0
		
		inc numCorrectWords
		call updateWPM
	notCleared:
	ret
tryClearWord ENDP



renderCurrWord PROC uses EAX EBX EDX ESI
	.IF cBIndex == 0
		ret
	.ENDIF
	
	mov ESI, cBIndex
	mov EBX, currWBAddress
	mGotoxy (GAMEWORD PTR [EBX]).xPos, (GAMEWORD PTR [EBX]).yPos
	mov EDX, OFFSET charBuffer

	mov EAX, green
	call SetTextColor
	
	mov AL, [EBX + ESI - 1]
	cmp AL, charBuffer[ESI - 1]
	je equal
		mov charBuffer[ESI - 1], 0
		dec cBIndex

		call WriteString
		mov EAX, red
		call SetTextColor

		mov AL, [EBX + ESI - 1]
		call WriteChar
		dec numCorrectKeys
		jmp notEqual
	equal:
		call WriteString
	notEqual:

	call updateAccuracy
	mov EAX, lightGray
	call SetTextColor
	ret
renderCurrWord ENDP



updateWPM PROC uses EAX EBX EDX
	mov EAX, numCorrectWords
	mov EBX, 60
	mul EBX

	mov EDX, 0
	mov EBX, elapsedTime
	div EBX

	mov WPM, EAX
	ret
updateWPM ENDP



updateAccuracy PROC uses EAX EBX EDX
	mov EAX, numCorrectKeys
	mov EBX, 100
	mul EBX

	mov EDX, 0
	mov EBX, numTotalKeys
	div EBX

	mov accuracy, EAX
	ret
updateAccuracy ENDP



searchWordBank PROC uses ECX EDX ESI EDI
	mov ESI, OFFSET wordBank + SIZEOF wordBank - TYPE wordBank
	mov ECX, LENGTHOF wordBank
	mov EDI, currWBAddress

	.IF currWBAddress == -1
		mov EDI, ESI
	.ENDIF

	firstCharMatch:
		mov DH, (GAMEWORD PTR [ESI]).yPos
		mov DL, (GAMEWORD PTR [EDI]).yPos
		.IF AL == [ESI] && DH > DL
			test (GAMEWORD PTR [ESI]).states, 10000000b
			jz isNotVisible
				mov currWBAddress, ESI
				mov EDI, currWBAddress
		.ENDIF
		isNotVisible:

		sub ESI, TYPE wordBank
	loop firstCharMatch
	ret
searchWordBank ENDP



fallingWordsDriver PROC uses EAX EDX
	call GetMseconds
	mov currSec, EAX
	add currSec, 1000

	fallingWords:
		call GetMseconds
		call tryForKey

		.IF EAX >= currSec
			inc elapsedTime
			call wipeScreen
			
			.IF maxWordsInGame != 0
				call spawnNewWord
			.ENDIF
			dec maxWordsInGame
			
			call fallWords
			.IF gameOver == 1
				call wipeScreen
				call renderOverlay
				ret
			.ENDIF

			add currSec, 1000
		.ENDIF
		call renderOverlay

	jmp fallingWords
	ret
fallingWordsDriver ENDP



dictionaryDriver PROC uses EAX EDX ESI
	call GetMseconds
	mov currSec, EAX
	add currSec, 1000	

	call printWords
	mov currWBAddress, OFFSET wordBank
	mov ESI, currWBAddress
	
	typeWords:
		call GetMseconds
		call tryForKeyDict

		test (GAMEWORD PTR [ESI]).states, 10000000b
		jnz notCleared
			add ESI, TYPE wordBank
			mov currWBAddress, ESI

			.IF BYTE PTR [ESI] == 0
				call wipeScreen
				call renderOverlay
				ret
			.ENDIF
		notCleared:

		.IF EAX >= currSec
			inc elapsedTime
			add currSec, 1000
		.ENDIF
		call renderOverlay

	jmp typeWords
	ret
dictionaryDriver ENDP



printWords PROC uses EAX EBX ECX EDX ESI
	mGotoxy 0, 1
	mov EBX, 1
	mov EAX, 0
	mov ESI, 0
	mov ECX, LENGTHOF wordBank - 1
	mov EDX, OFFSET wordBank

	printWordBank:
		mov (GAMEWORD PTR [EDX]).xPos, AL
		mov (GAMEWORD PTR [EDX]).yPos, BL
		or (GAMEWORD PTR [EDX]).states, 10000000b

		call WriteString
		mWriteSpace 1

		call StrLength
		add EDX, TYPE wordBank
		add ESI, EAX
		inc ESI
		mov EAX, ESI

		inc BH
		.IF BH == 10
			inc BL
			mGotoxy 0, BL
			mov BH, 0
			mov ESI, 0
			mov AL, 0
		.ENDIF
	loop printWordBank
	ret
printWords ENDP



mainMenu PROC uses EAX EDX
	restartMenu:

	mov accuracy, 0
	mov numCorrectKeys, 0
	mov numTotalKeys, 0
	mov WPM, 0
	mov numCorrectWords, 0
	mov elapsedTime, 0
	mov gameOver, 0
	mov cBIndex, 0
	mov currWBAddress, -1
	mov EAX, 0
	.WHILE charBuffer[EAX] != 0
		mov charBuffer[EAX], 0
	.ENDW

	call wipeScreen
	mGotoxy 40, 8
	mWrite "CS66 Final"
	mGotoxy 40, 9
	mWrite "by Zachary Padilla"
	mGotoxy 40, 11
	mWrite "[1] Falling Words"
	mGotoxy 40, 12
	mWrite "[2] Dictionary"
	mGotoxy 40, 13
	mWrite "[3] Exit"
	
	mov AL, 0
	call ReadChar
	.IF AL == "1"
		call wipeScreen
		call fallingWordsDriver
	.ELSEIF AL == "2"
		call wipeScreen
		call dictionaryDriver
	.ELSEIF AL == "3"
		ret
	.ELSE
		jmp restartMenu
	.ENDIF

	mGotoxy 0, 1
	mWrite "Good job! Press [x] to return to the main menu."
	.WHILE AL != "x"
		call ReadChar
	.ENDW
	jmp restartMenu
	ret
mainMenu ENDP



main PROC
	call Randomize
	call mainMenu
	call Crlf
exit


main ENDP
END main