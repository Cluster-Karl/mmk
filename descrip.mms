!++
!   DESCRIP.MMS
!
!   Description file for building MMK.
!   Copyright (c) 2008, Matthew Madison.
!   Copyright (c) 2012, Endless Software Solutions.
!
!   All rights reserved.
!
!   Redistribution and use in source and binary forms, with or without
!   modification, are permitted provided that the following conditions
!   are met:
!
!       * Redistributions of source code must retain the above
!         copyright notice, this list of conditions and the following
!         disclaimer.
!       * Redistributions in binary form must reproduce the above
!         copyright notice, this list of conditions and the following
!         disclaimer in the documentation and/or other materials provided
!         with the distribution.
!       * Neither the name of the copyright owner nor the names of any
!         other contributors may be used to endorse or promote products
!         derived from this software without specific prior written
!         permission.
!
!   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
!   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
!   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
!   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
!   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
!   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
!   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
!   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
!   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
!   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!       
!   28-SEP-1993	V1.0	Madison	    Initial commenting.
!   25-JUL-1994	V1.1	Madison	    Update for V3.2.
!   27-DEC-1998	V1.2	Madison	    Update for V3.8.
!   03-MAY-2004 V1.3    Madison     Integrate IA64 support.
!   03-MAR-2008 V2.0    Madison     Cleanup for open-source release.
!   05-JUL-2009 V2.1    Sneddon     Added HTML documentation.
!   16-APR-2010 V2.2	Sneddon     New modules, etc.
!   06-AUG-2010 V2.3	Sneddon     Add release notes, plus SDML dynamic
!				     symbols.
!--

.IFDEF ARCH
.ELSE
.IFDEF MMS$ARCH_NAME
ARCH = $(MMS$ARCH_NAME)
.ELSE
.ERROR You must define the ARCH macro as one of: VAX, ALPHA, IA64
.ENDIF
.ENDIF

.SUFFIXES : .PS .PDF
.PS.PDF :
    < DEFINE/USER GS_LIB SYS$SYSDEVICE:[GS.LIB],SYS$SYSDEVICE:[GS.FONTS]
    < GS == "$SYS$SYSDEVICE:[GS.BIN]GS.EXE_$(MMSARCH_NAME)"
    - PIPE GS "-sDEVICE=pdfwrite" "-dBATCH" "-dNOPAUSE" "-sOutputFile=$(MMS$TARGET)" $(MMS$SOURCE) > $(MMS$TARGET:.pdf=.gs_out)
    > TYPE $(MMS$TARGET:.pdf=.gs_out)
    > IF F$SEARCH("$(MMS$TARGET:.pdf=.gs_out)") .NES. "" THEN DELETE/NOLOG $(MMS$TARGET:.pdf=.gs_out);*
    > DELETE/SYMBOL/GLOBAL GS
    > IF F$SEARCH("_TEMP_*.*") .NES. "" THEN DELETE/NOLOG _TEMP_*.*;*

.IFDEF __MADGOAT_BUILD__
MG_FACILITY = MMK
SRCDIR = MG_SRC:[MMK]
BINDIR = MG_BIN:[MMK]
ETCDIR = MG_ETC:[MMK]
KITDIR = MG_KIT:[MMK]
.ELSE
SRCDIR = SYS$DISK:[]
BINDIR = SYS$DISK:[.BIN-$(ARCH)]
ETCDIR = SYS$DISK:[.ETC-$(ARCH)]
KITDIR = SYS$DISK:[.KIT-$(ARCH)]
.ENDIF
.FIRST
    @ IF F$PARSE("$(BINDIR)") .EQS. "" THEN CREATE/DIR $(BINDIR)
    @ DEFINE/NOLOG BIN_DIR $(BINDIR)
    @ IF F$PARSE("$(ETCDIR)") .EQS. "" THEN CREATE/DIR $(ETCDIR)
    @ DEFINE/NOLOG ETC_DIR $(ETCDIR)
    @ IF F$PARSE("$(KITDIR)") .EQS. "" THEN CREATE/DIR $(KITDIR)
    @ DEFINE/NOLOG KIT_DIR $(KITDIR)
    @ DEFINE/NOLOG SRC_DIR $(SRCDIR)
    @ IF F$TRNLNM("MMK_SDL_SETUP") .NES. "" -
	THEN @MMK_SDL_SETUP:

OPT = .$(ARCH)_OPT
MMKCOPT = MMK_COMPILE_RULES$(OPT)

SDL = SDL/VAX

.IFDEF DBG
CFLAGS = $(CFLAGS)/DEBUG/NOOPT/LIST=$(ETCDIR)
.IFDEF __VAX__
CFLAGS = $(CFLAGS)/MACHINE=AFTER
.ELSE
CFLAGS = $(CFLAGS)/MACHINE
.ENDIF
LINKFLAGS = $(LINKFLAGS)/TRACEBACK
.ENDIF

!
! Modules for building MMK
!
OBJECTS = MMK=$(BINDIR)MMK.OBJ,FILEIO=$(BINDIR)FILEIO.OBJ,-
          MEM=$(BINDIR)MEM.OBJ,GET_RDT=$(BINDIR)GET_RDT.OBJ,-
          SP_MGR=$(BINDIR)SP_MGR.OBJ,MISC=$(BINDIR)MISC.OBJ,-
          OBJECTS=$(BINDIR)OBJECTS.OBJ,SYMBOLS=$(BINDIR)SYMBOLS.OBJ,-
          READDESC=$(BINDIR)READDESC.OBJ,-
          BUILD_TARGET=$(BINDIR)BUILD_TARGET.OBJ,-
          PARSE_DESCRIP=$(BINDIR)PARSE_DESCRIP.OBJ,-
          CMS_INTERFACE=$(BINDIR)CMS_INTERFACE.OBJ,-
          PARSE_OBJECTS=$(BINDIR)PARSE_OBJECTS.OBJ,-
          PARSE_TABLES=$(BINDIR)PARSE_TABLES.OBJ,-
          MMK_MSG=$(BINDIR)MMK_MSG.OBJ,MMK_CLD=$(BINDIR)MMK_CLD.OBJ,-
          DEFAULT_RULES=$(BINDIR)DEFAULT_RULES.OBJ
!
! Modules for building the rules compiler
!
MMKCMODS = FILEIO=$(BINDIR)FILEIO.OBJ,MEM=$(BINDIR)MEM.OBJ,-
           MISC=$(BINDIR)MISC.OBJ,OBJECTS=$(BINDIR)OBJECTS.OBJ,-
           SYMBOLS=$(BINDIR)SYMBOLS.OBJ,-
           READDESC=$(BINDIR)READDESC.OBJ,-
           PARSE_DESCRIP=$(BINDIR)PARSE_DESCRIP.OBJ,-
           PARSE_OBJECTS=$(BINDIR)PARSE_OBJECTS.OBJ,-
           PARSE_TABLES=$(BINDIR)PARSE_TABLES.OBJ,-
           MMK_MSG=$(BINDIR)MMK_MSG.OBJ

CFLAGS = /NODEBUG$(CFLAGS)$(DEFINE)
LINKFLAGS = /NOTRACEBACK/NODEBUG$(LINKFLAGS)

$(BINDIR)MMK.EXE : $(BINDIR)MMK.OLB($(OBJECTS)),$(SRCDIR)MMK$(OPT)
    $(LIBR)/COMPRESS/OUTPUT=$(BINDIR)MMK.OLB $(BINDIR)MMK.OLB
    $(LINK)$(LINKFLAGS) $(SRCDIR)MMK$(OPT)/OPT

MMK_H	    	    	    = $(SRCDIR)MMK.H, $(ETCDIR)MMK_MSG.H

$(BINDIR)MMK.OBJ            : $(SRCDIR)MMK.C,$(MMK_H) $(SRCDIR)VERSION.H
$(BINDIR)MEM.OBJ            : $(SRCDIR)MEM.C,$(MMK_H)
$(BINDIR)SP_MGR.OBJ         : $(SRCDIR)SP_MGR.C,$(MMK_H)
$(BINDIR)FILEIO.OBJ         : $(SRCDIR)FILEIO.C,$(MMK_H)
$(BINDIR)GET_RDT.OBJ	    : $(SRCDIR)GET_RDT.C,$(MMK_H)

$(BINDIR)SYMBOLS.OBJ        : $(SRCDIR)SYMBOLS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)OBJECTS.OBJ        : $(SRCDIR)OBJECTS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)MISC.OBJ           : $(SRCDIR)MISC.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)READDESC.OBJ       : $(SRCDIR)READDESC.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)BUILD_TARGET.OBJ   : $(SRCDIR)BUILD_TARGET.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_DESCRIP.OBJ  : $(SRCDIR)PARSE_DESCRIP.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_OBJECTS.OBJ  : $(SRCDIR)PARSE_OBJECTS.C,$(MMK_H),$(SRCDIR)GLOBALS.H
$(BINDIR)CMS_INTERFACE.OBJ  : $(SRCDIR)CMS_INTERFACE.C,-
                              $(MMK_H),$(SRCDIR)CMSDEF.H,$(SRCDIR)GLOBALS.H
$(BINDIR)PARSE_TABLES.OBJ   : $(SRCDIR)PARSE_TABLES.MAR
    $(MACRO)$(MFLAGS) SYS$LIBRARY:ARCH_DEFS.MAR+$(SRCDIR)PARSE_TABLES.MAR

$(BINDIR)DEFAULT_RULES.OBJ  : $(SRCDIR)DEFAULT_RULES.C,$(MMK_H),$(SRCDIR)GLOBALS.H,-
                              $(ETCDIR)MMK_DEFAULT_RULES.H

$(BINDIR)MMK_MSG.OBJ        : $(SRCDIR)MMK_MSG.MSG
$(BINDIR)MMK_CLD.OBJ        : $(SRCDIR)MMK_CLD.CLD

$(ETCDIR)MMK_MSG.H	    : $(SRCDIR)MMK_MSG.MSG
    $(MESSAGE)/NOOBJECT/SDL=$(ETCDIR)MMK_MSG.SDL $(MMS$SOURCE)
    $(SDL)/LANGUAGE=CC=$(MMS$TARGET) $(ETCDIR)MMK_MSG.SDL

$(ETCDIR)MMK_DEFAULT_RULES.H : $(SRCDIR)MMK_DEFAULT_RULES_$(ARCH).MMS, $(BINDIR)MMK_COMPILE_RULES.EXE
    MMKC := $$(BINDIR)MMK_COMPILE_RULES.EXE
    MMKC/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE)

MMKCOBJ = $(BINDIR)MMK_COMPILE_RULES.OBJ,$(BINDIR)GENSTRUC.OBJ,$(BINDIR)MMK_COMPILE_RULES_CLD.OBJ

$(BINDIR)MMK_COMPILE_RULES_CLD.OBJ : $(SRCDIR)MMK_COMPILE_RULES_CLD.CLD

$(BINDIR)MMK_COMPILE_RULES.EXE : $(MMKCOBJ),$(BINDIR)MMK.OLB($(MMKCMODS)),$(MMKCOPT)
    $(LINK)$(LINKFLAGS) $(MMKCOBJ),$(SRCDIR)$(MMKCOPT)/opt

$(BINDIR)MMK_COMPILE_RULES.OBJ	: $(SRCDIR)MMK_COMPILE_RULES.C,$(MMK_H)
$(BINDIR)GENSTRUC.OBJ	       	: $(SRCDIR)GENSTRUC.C,$(MMK_H),$(SRCDIR)GLOBALS.H

!
! The help file
!
$(KITDIR)MMK_HELP.HLP : $(SRCDIR)MMK_HELP.RNH

!
! Documentation
!
DOCS : $(KITDIR)MMK_DOC.PS,$(KITDIR)MMK_DOC.TXT,$(KITDIR)MMK_DOC.HTML,-
	$(KITDIR)MMK_HELP.HLP,$(KITDIR)MMK.RELEASE_NOTES $(KITDIR)MMK_DOC.PDF
$(KITDIR)MMK_DOC.PS : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,-
                      $(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS,-
		      $(ETCDIR)DYNAMIC_SYMBOLS.SDML
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/NOPRINT/DEVICE=BLANK_PAGES/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE) SOFTWARE.REFERENCE PS
$(KITDIR)MMK_DOC.PDF : $(KITDIR)MMK_DOC.PS
$(KITDIR)MMK_DOC.TXT : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,-
                       $(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS,-
		       $(ETCDIR)DYNAMIC_SYMBOLS.SDML
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/NOPRINT/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE) SOFTWARE.REFERENCE MAIL
$(KITDIR)MMK_DOC.HTML : $(SRCDIR)MMK_DOC.SDML,$(SRCDIR)MMK_DEFAULT_RULES_VAX.MMS,-
			$(SRCDIR)MMK_DEFAULT_RULES_ALPHA.MMS,$(SRCDIR)MMK_DEFAULT_RULES_IA64.MMS,-
			$(ETCDIR)DYNAMIC_SYMBOLS.SDML
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/CONTENTS/OUTPUT=$(KITDIR) $(MMS$SOURCE) SOFTWARE.REFERENCE HTML
$(KITDIR)MMK.RELEASE_NOTES : $(SRCDIR)RELEASE_NOTES.SDML,$(ETCDIR)DYNAMIC_SYMBOLS.SDML
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEF/USER DECC$SHR SYS$SHARE:DECC$SHR
    DOCUMENT/DEVICE=BLANK_PAGES/OUTPUT=$(MMS$TARGET) $(MMS$SOURCE) SOFTWARE.REFERENCE MAIL/CONTENTS
$(ETCDIR)DYNAMIC_SYMBOLS.SDML   : $(BINDIR)MMK.EXE,$(SRCDIR)GENERATE_SYMBOLS.MMS
    MCR $(MMS$SOURCE) /DESCRIPTION=$(SRCDIR)GENERATE_SYMBOLS.MMS -
		/OUTPUT=$(MMS$TARGET)

CLEAN :
    - DELETE $(ETCDIR)*.*;*
    - DELETE $(KITDIR)*.*;*
    - DELETE $(BINDIR)*.*;*

REALCLEAN : CLEAN
    - DELETE $(KITDIR)*.*;*

.IFDEF ZIP
.ELSE
ZIP = ZIP
.ENDIF

ALWAYS_MAKE : ! fake target to trigger make on every pass

.IFNDEF KITBUILDER

!
! Build new MMK version number...
!
TMP != PIPE TMP="$(MMK_MAJOR_VERSION)" ; IF F$LENGTH(TMP) .EQ 1 THEN TMP="0"+TMP ; WRITE/SYMBOL SYS$OUTPUT TMP
KITNAME = $(COLLAPSE $(MG_FACILITY)$(TMP)$(MMK_MINOR_VERSION))

KIT : $(BINDIR)MMK.EXE
    MCR $(BINDIR)MMK.EXE /MACRO=(KITBUILDER=1,KITNAME=$(KITNAME)) VMSINSTAL
    MCR $(BINDIR)MMK.EXE /MACRO=(KITBUILDER=1,KITNAME=$(KITNAME)) PCSI

.ELSE

!
! MMK VMSINSTAL Kit Lettering...
!
! A = KITINSTAL, documentation
! B = VAX images
! C = Alpha images
! D = I64 images
! E = Source code
!
BACKUP = BAC/INT/BL=8192

VMSINSTAL : $(KITDIR)$(KITNAME).A,$(KITDIR)$(KITNAME).B,-
	    $(KITDIR)$(KITNAME).C,$(KITDIR)$(KITNAME).D,$(KITDIR)$(KITNAME).E
    @ WRITE SYS$OUTPUT "%I, MMK VMSINSTAL kit built"

$(KITDIR)$(KITNAME).RELEASE_NOTES : $(KITDIR)MMK.RELEASE_NOTES
    COPY $(MMS$SOURCE) $(MMS$TARGET)

$(KITDIR)$(KITNAME).A : $(SRCDIR)KITINSTAL.COM,-
			$(KITDIR)$(KITNAME).RELEASE_NOTES,-
			$(KITDIR)MMK_INSTALLING_VERSION.DAT,-
			$(KITDIR)MMK_DOC_LIST.DAT,$(SRCDIR)MMK_CLD.CLD,-
			$(KITDIR)MMK_HELP.HLP
    - PURGE/NOLOG $(MMS$SOURCE_LIST),-
	MG_KIT:[MMK]*.PDF,*.PS,*.HTML,*.TXT
    SET PROTECTION=W:RE $(MMS$SOURCE_LIST),-
	MG_KIT:[MMK]*.PDF,*.PS,*.HTML,*.TXT
    $(BACKUP) $(MMS$SOURCE_LIST),MG_KIT:[MMK]*.PDF,*.PS,*.HTML,*.TXT -
	$(MMS$TARGET)/SA

$(KITDIR)MMK_DOC_LIST.DAT : MAKE_MMK_DOC_LIST.COM,DOCS
    -@ DELETE/NOLOG $(MMS$TARGET);*
    @MAKE_MMK_DOC_LIST

$(KITDIR)MMK_INSTALLING_VERSION.DAT : $(SRCDIR)INSTALLING_VERSION.MMS,-
				      $(BINDIR)MMK.EXE
    MCR $(BINDIR)MMK.EXE /DESCRIPTION=$(MMS$SOURCE)/OUTPUT=$(MMS$TARGET)

$(KITDIR)$(KITNAME).B : MG_BIN_VAX:[MMK]MMK.EXE
    - PURGE/NOLOG $(MMS$SOURCE_LIST)
    SET PROTECTION=W:RE $(MMS$SOURCE_LIST)
    $(BACKUP) $(MMS$SOURCE_LIST) $(MMS$TARGET)/SA

$(KITDIR)$(KITNAME).C : MG_BIN_AXP:[MMK]MMK.EXE
    - PURGE/NOLOG $(MMS$SOURCE_LIST)
    SET PROTECTION=W:RE $(MMS$SOURCE_LIST)
    $(BACKUP) $(MMS$SOURCE_LIST) $(MMS$TARGET)/SA

$(KITDIR)$(KITNAME).D : MG_BIN_I64:[MMK]MMK.EXE
    - PURGE/NOLOG $(MMS$SOURCE_LIST)
    SET PROTECTION=W:RE $(MMS$SOURCE_LIST)
    $(BACKUP) $(MMS$SOURCE_LIST) $(MMS$TARGET)/SA

$(KITDIR)$(KITNAME).E : $(KITDIR)$(KITNAME)_SOURCE.ZIP
    - PURGE/NOLOG $(MMS$SOURCE_LIST)
    SET PROTECTION=W:RE $(MMS$SOURCE_LIST)
    $(BACKUP) $(MMS$SOURCE_LIST) $(MMS$TARGET)/SA

$(KITDIR)$(KITNAME)_SOURCE.ZIP : ALWAYS_MAKE
    - DELETE/NOLOG $(MMS$TARGET);*
    wget --no-check-certificate --output-document=$(MMS$TARGET) -
	"https://github.com/endlesssoftware/mmk/archive/$(MMK_VERSION).zip"

PCSI : $(KITDIR)MMK.PCSI$DESC $(KITDIR)MMK.PCSI$TEXT
    MCR $(BINDIR)MMK.EXE PACKAGE/DESCRIPTION=$(SRCDIR)MMK_PCSI.MMS

$(KITDIR)MMK.PCSI$DESC : $(SRCDIR)MMK_PCSI.MMS
    MCR $(BINDIR)MMK.EXE DESCRIPTION/OUTPUT=$(MMS$TARGET) -
	/DESCRIPTION=$(MMS$SOURCE)

$(KITDIR)MMK.PCSI$TEXT : $(SRCDIR)MMK_PCSI.MMS
    MCR $(BINDIR)MMK.EXE TEXT/OUTPUT=$(MMS$TARGET) -
	/DESCRIPTION=$(MMS$SOURCE)

.ENDIF
