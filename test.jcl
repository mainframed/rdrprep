//TEST JOB CLASS=A,MSGLEVEL=(1,1)
//UPDTE    EXEC PGM=IEBUPDTE
//SYSPRINT  DD  SYSOUT=A
//SYSUT1    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSUT2    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSIN     DD  *
./ ADD NAME=JUNK
::a first.include.txt
./ ADD NAME=IEFBR14
::a iefbr14.asm
//LINK     EXEC PGM=IEWL,PARM='MAP'
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DISP=SHR,DSN=SYS2.LOCAL.LINKLIB(IEFBR14) 
//SYSUT1    DD UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSLIN    DD *
::e iefbr14.obj
//IEFBR14  EXEC PGM=IEFBR14
//STEPLIB   DD DSN=SYS2.LOCAL.LINKLIB,DISP=SHR 
//

