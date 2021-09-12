; this example shows how to access virtual ports (0 to 65535).
; these ports are emulated in this file: c:\emu8086.io

; this technology allows to make external add-on devices
; for emu8086, such as led displays, robots, thermometers, stepper-motors, etc... etc...

; anyone can create an animated virtual device.

; c:\emu8086\devices\led_display.exe

#start=Traffic_Lightsm8.exe# ;import the customize virtual device


#make_bin#

name "Traffic lights w/ Timer"      


mov     ax, all_red 
out     4, ax
;initialize value
mov     si, offset situation    ;initialize the lanes 
mov     ax, 4                   ;send the data to virtual device lights
mov     si, ax 
mov     ax, 0 
out     61, ax                  ;set the counter for top -> bottom lane to 0 
out     51, ax                  ;set the counter for L -> R lane to 0 
out     63, ax                  ;set the counter for T -> B lane to 0 
out     53, ax                  ;set the counter for R -> L lane to 0 
out     10, ax                  ;set car speed to fast/light 
out     250, ax                 ;set the vertical timer to 0
out     200, ax                 ;set the horizontal timer to 0
mov     Log, ax                 
mov     SetDefaultTS, ax        ;set the variable default setting to on
mov     SetDefaultTT, ax        ;set the variable default setting to on
mov     counter_T_B, ax         ;set the counter variable to 0
out     61, ax 
mov     counter_L_R, ax
out     51, ax
mov     counter_B_T,ax 
out     63, ax
mov     counter_R_L, ax
out     53, ax
mov     LogCounter, ax          ;set the status interval to 0 


;officially starts the device    

vertical:                       ;vertical lane
mov     ax, 5                   ;save the current lane to get back later
mov     currentPlane, ax         
jmp     CheckTT                 ;then jump to check the setting
returnv:
mov     ax, timerGR[si]         ;move the data to ax                    
mov     timer, ax               ;move the date to timer variable             
out     250, ax                 ;send data to virtual device for timer           
out     200, ax                 ;send data to virtual device for timer                    
mov     ax, 0000_0011_0000_1100b;set the traffic lights            
out     4, ax                   ;send the data to virtual device                            
mov     ax, 0                   ;set the ax value to 0                            
out     100, ax                 ;send the data for the color of the timer           
mov     ax, 2                               
out     150, ax 
mov     cx, 0                   ;set the counter to 0   
mov     countdown, cx           ;save the date to variable
mov     ax, 0                   ;set the new plane but for the updating of vertical lane
mov     currentPlane, ax                            
x1:                             ;this will keep updating if its not time to change lane
mov     ax, LogCounter          ;move the data of LogCounter to ax                   
cmp     ax, 59                  ;compare if the data is greater or equal to 59
jge     get_time                ;if true, the log/message will update
mov     ax, timeroffset[si]     ;move the data to ax
mov     cx, countdown           
cmp     ax, cx                  ;compare to countdown = compare if its time to change the lanes                         
je      transition_horizontal   ;now moving to transition to horizontal           
mov     ah, 2ch                 ;else, it will check time, if its time to change the timer of the lanes            
int     21h 
mov     AL,DH                               
cmp     AL, currentSysTimeS                        
JNE     update_timer            ;if the save variable didnt match to current system time, it will update the timer of lanes and counts car                      
jmp     x1                      ;else it will go back

;this is the same instructions to horizontal
                                  

transition_horizontal:
mov     ax, 1                       ;sets the new plane for updating
mov     currentPlane, ax            ;save to variable
mov     ax, 0000_0010_1000_1010b    ;update the color traffic lights to the whole lane
out     4, ax                       ;send the updated data to virtual device   
mov     ax, 1
out     100, ax                     ;update the color of the timer
mov     ax, 2
out     150, ax                     ;update the color of the timer
mov     cx, 0   
mov     countdown, cx               ;set the countdown to 0 then save to variable
x4:   
mov     ax, timerY[si]              ;get the timer for the cooldown to stop the cars 
mov     cx, countdown               ;if its time to go new lane 
cmp     ax, cx                           
je      horizontal                  ;go to new lane 
mov     ah, 2ch                     ;else it will keep updating the time and count cars        
int     21h 
mov     AL,DH                               
cmp     AL, currentSysTimeS                        
JNE     update_timer                        
jmp     x4 


horizontal:
mov     ax, 6
mov     currentPlane, ax  
jmp     CheckTT 
returnh:
mov     ax, timerGR[si]    
mov     timer, ax    
out     250, ax 
out     200, ax 
mov     cx, 0 
mov     ax, 0000_1000_0110_0001b
out     4, ax
mov     ax, 2
out     100, ax
mov     ax, 0
out     150, ax
mov     cx, 0   
mov     countdown, cx
mov     ax, 2
mov     currentPlane, ax   
x2:  
mov     ax, LogCounter                                
cmp     ax, 59         
jge     get_time 
mov     ax, timeroffset[si] 
mov     cx, countdown                
cmp     ax, cx                           
je      transition_vertical              
mov     ah, 2ch                             
int     21h 
mov     AL,DH                               
cmp     AL, currentSysTimeS                        
JNE     update_timer                                               
jmp     x2  


transition_vertical: 
mov     ax, 3
mov     currentPlane, ax 
mov     ax, 0000_0100_0101_0001b
out     4, ax        
mov     ax, 2
out     100, ax
mov     ax, 1
out     150, ax    
mov     cx, 0   
mov     countdown, cx 
x3: 
mov     ax, timerY[si] 
mov     cx, countdown                
cmp     ax, cx                           
je      vertical              
mov     ah, 2ch                                                 
int     21h 
mov     AL,DH                               
cmp     AL, currentSysTimeS                        
JNE     update_timer   
jmp     x3   


update_timer: 
mov     currentSysTimeS, AL     ;this will update the timer of the lanes
mov     ax, LogCounter          ;increment the log counter
inc     ax
mov     LogCounter, ax          ;then save to variable              
mov     ax, timer                           
mov     cx, countdown
dec     ax
out     250, ax                 ;update the timer of lanes                                                
out     200, ax                 ;update the timer of lanes   
mov     timer, ax  
inc     cx 
mov     countdown, cx    

mov     ah, 2Ch                 ;update the time                                                
int     21h 
mov     al, CL                  ;hour
out     113, al
mov     ah, 2Ch                                                  
int     21h 
mov     al, DH                  ;min 
out     115, al
mov     ah, 2Ch                                                  
int     21h 
mov     al, CH                  ;sec
out     30, al


                                ;this will update the date
mov     ah, 2Ah                                                  
int     21h 
mov     ax, CX
out     160, ax                 ;send the current year to virtual
mov     ah, 2Ah                                                  
int     21h 
mov     al, DH 
out     162, al                 ;send current month
mov     ah, 2Ah                                                  
int     21h 
mov     al, dl
out     164, al                 ;send current day



carCounter:                 ;count the cars passing thru each lane 
in      ax, 61              ;get data from virtual device
mov     counter_T_B, ax     ;save the data to virtual device
out     61, ax              ;send the data to virtual device
in      ax, 51  
mov     counter_L_R, ax
out     51, ax 
in      ax, 63
mov     counter_B_T,ax 
out     63, ax 
in      ax, 53 
mov     counter_R_L, ax
out     53, ax


CheckTS:                    ;check if the flow setting is in default or custom  
in      ax, 80              ;get data from virtual
mov     SetDefaultTS, ax    ;save the setting to a variable
mov     ax, 1               ;send data to virtual
cmp     ax, SetDefaultTS
je      SetDefaultFlow
jmp     Set_Custom_Flow
   
CheckTT:                    ;check if the time setting is in default or custom                                                                
in      ax, 95
mov     SetDefaultTT, ax  
mov     ax, 1
cmp     ax, SetDefaultTT
je      SetDefaultTimer 
je      Set_Custom_Time

        
;timer = port(85)
;flow  = port(20) & port(10)
Set_Custom_Time:            ;if the user decided to custom the time
in      ax, 15              ;get the time from virtual device
mov     si, ax 
out     85, ax              ;send the time to virtual device
jmp     getplane

Set_Custom_Flow:            ;if the user decided to custom the flow           
in      ax, 20              ;get the time from virtual device
out     10, ax              ;get the time from virtual device
mov     CurrentFlow, ax

getplane:                   ;go to their respective functions
mov     ax, currentPlane
cmp     ax, 0
je      x1                  ;go back to x1 
cmp     ax, 1
je      x4                  ;go back to x4 
cmp     ax, 2
je      x2                  ;go back to x2 
cmp     ax, 3
je      x3                  ;go back to x3 
cmp     ax, 5
je      returnv             ;go back to returnv 
cmp     ax, 6
je      returnh             ;go back to returnh 

 
SetDefaultFlow:             ;this will check the pre-determined specific time
mov     ah, 2ch             ;set the flow of traffic                           
int     21h 
mov     al, ch
cmp     al, 4  
jle      Set_Traffic_S_L
cmp     al, 5  
jl      Set_Traffic_S_M 
cmp     al, 8  
jl      Set_Traffic_S_H
cmp     al, 8  
je      Set_Traffic_S_M
cmp     al, 16  
jl      Set_Traffic_S_L
cmp     al, 17  
jl      Set_Traffic_S_M 
cmp     al, 19  
jl      Set_Traffic_S_H 
cmp     al, 20  
jl      Set_Traffic_S_M
cmp     al, 20  
jg      Set_Traffic_S_L
jmp     getplane 

SetDefaultTimer:            ;this will check will also check the pre-determined specific time
mov     ah, 2ch             ;but this will set the timer for the lanes                             
int     21h 
mov     al, ch
cmp     al, 4               ;equal and less than 4 am
jle     Set_Traffic_T_L     
cmp     al, 6               ;less than 4 am
jl      Set_Traffic_T_M 
cmp     al, 8               ;less than 8 am
jl      Set_Traffic_T_H
cmp     al, 8               ;equal 8 am
je      Set_Traffic_T_M
cmp     al, 16              ;less than 4 pm
jl      Set_Traffic_T_L
cmp     al, 17              ;less than 5 pm
jl      Set_Traffic_T_M 
cmp     al, 18              ;less than 6 pm
jl      Set_Traffic_T_H 
cmp     al, 20              ;less than 8 pm
jl      Set_Traffic_T_M
cmp     al, 20              ;more than 8 pm
jg      Set_Traffic_T_L  
jmp     getplane  

;speed of cars = port(10)
                     
Set_Traffic_S_L:                ;set traffic to light
mov     ax, 0 
mov     CurrentFlow, ax  
out     10, ax      
jmp     getplane                ;go back to plane


Set_Traffic_S_M:                ;set traffic to moderate
mov     ax, 1  
mov     CurrentFlow, ax 
out     10, ax
jmp     getplane


Set_Traffic_S_H:                ;set traffic to heavy 
mov     ax, 2 
mov     CurrentFlow, ax 
out     10, ax
jmp     getplane  

;timer interval = port(85)

Set_Traffic_T_L:                ;set timer to 15 secs
mov     si, 4
mov     ax, si   
out     85, ax
jmp     getplane


Set_Traffic_T_M:                ;set timer to 30 secs 
mov     si, 2 
mov     ax, si  
out     85, ax
jmp     getplane


Set_Traffic_T_H:                ;set timer to 60 secs  
mov     si, 0 
mov     ax, si  
out     85, ax
jmp     getplane

 

;update_log       = port(105)
;hour             = port(30)
;minute           = port(113)
;traffic flow     = port(195)  

get_time:                       ;get the time 
mov     ax, 0
mov     LogCounter, ax
mov     ah, 2ch                             
int     21h 
mov     AL,CH                               
mov     CurrentSysTimeH, al     ;get the current time(hour)
mov     ah, 2ch                             
int     21h 
mov     AL,CL                                
mov     CurrentSysTimeM, al     ;get the current time(minute)

mov     ax, Log                 ;get the status of the traffic
out     210, ax
mov     ax, 1
out     105, ax                 
mov     al, CurrentSysTimeH     
out     30, al                  ;send data to virtual device (hour)
mov     al, CurrentSysTimeM
out     113, al                 ;send data to virtual device (minute)  

mov     ax, Log
inc     ax
mov     Log, ax 
mov     ax, CurrentFlow         ;get the current flow 
cmp     ax, 0                   ;check if the current flow is light
je      print_light             ;if its true it will jump to print_light
cmp     ax, 1                   ;
je      print_moderate          ;
cmp     ax, 2                   ;
je      print_heavy             ;
        
 
print_light:
mov     ax, 0                   
out     195, ax                 ;send data to virtual device
jmp     getplane   
print_moderate:
mov     ax, 3
out     195, ax
jmp     getplane  
print_heavy:
mov     ax, 6   
out     195, ax
jmp     getplane    






;                           FEDC_BA98_7654_3210  
;vertical
situation           dw      0000_0011_0000_1100b
s1                  dw      0000_0010_1000_1010b
;horizontal
s2                  dw      0000_1000_0110_0001b
s3                  dw      0000_0100_0101_0001b
sit_end = $


all_red             dw      0000_0010_1000_1010b         

timer               dw      0 
timerGR             dw      60,30,15    
timerY              dw      5,4,3 
timeroffset         dw      55,26,12    
countdown           dw      0 
currentSysTimeS     db      0   
currentPlane        dw      0  
counter_B_T         dw      0  
counter_T_B         dw      0
counter_L_R         dw      0
counter_R_L         dw      0    
CurrentSysTimeM     db      0   
CurrentSysTimeH     db      0 
TotalCarPerMin      dw      0
LogCounter          dw      0 
Log                 dw      0 
CurrentFlow         dw      0
CurrentDay          db      0
CurrentMn           db      0
CurrentYr           dw      0
;0, 1, 2    
SetTrafficStatus    dw      0
SetTrafficTimerS    dw      0 
;0 off / 1 on   
SetDefaultTS        dw      0   ;port                  
SetDefaultTT        dw      0                  


