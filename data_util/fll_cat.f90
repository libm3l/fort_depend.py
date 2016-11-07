!
!     Copyright (C) 2016  Adam Jirasek
! 
!     This program is free software: you can redistribute it and/or modify
!     it under the terms of the GNU Lesser General Public License as published by
!     the Free Software Foundation, either version 3 of the License, or
!     (at your option) any later version.
! 
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!     GNU Lesser General Public License for more details.
! 
!     You should have received a copy of the GNU Lesser General Public License
!     along with this program.  If not, see <http://www.gnu.org/licenses/>.
!     
!     contact: libm3l@gmail.com
!
!     Subroutine FLL_CAT
!
!
MODULE FLL_CAT_M
!
! Description: Contains function fll_cp
!
! 
! History:
! Version   Date       Patch number  CLA     Comment
! -------   --------   --------      ---     -------
! 1.1       10/10/16                         Initial implementation
!
!
! External Modules used
!
CONTAINS

   SUBROUTINE FLL_CAT(PNODE,IOUNIT,PARENT,FPAR)
!
! Description: Module prints the short content of PNODE to IOUNIT
!
! External Modules used
!     
    USE FLL_TYPE_M
    USE FLL_OUT_M
    IMPLICIT NONE
!
! Declarations
!
! Arguments description
! Name         In/Out     Function
! PNODE        In         pointer to be printed
! IOUNIR       In         pointer which is to be copied
! PARENT       In         parameter, if .TRUE. write information about PNODE parent node
! FPAR         In/Out     structure containing function specific data
!
! Arguments declaration
!
   TYPE(DNODE), POINTER  :: PNODE
   TYPE(FUNC_DATA_SET) :: FPAR
   INTEGER :: IOUNIT
   LOGICAL :: PARENT
!
! Local types
!
   TYPE(DNODE), POINTER  :: PCHILD
   INTEGER(LINT) :: POS
! 
! body of subroutine
!
   POS = 1
   FPAR%SUCCESS = .FALSE.
   IF(.NOT.ASSOCIATED(PNODE))THEN
      WRITE(FPAR%MESG,'(A)')' CAT - null node '
      FPAR%SUCCESS = .FALSE.
      CALL FLL_OUT('ALL',FPAR)
      RETURN
   END IF

   WRITE(*,*)
   PCHILD => PNODE%PCHILD
   IF(PARENT) THEN
      IF(ASSOCIATED(PNODE%PPAR))WRITE(*,*)' ===> Node has a parent, its name is: ', PNODE%PPAR%LNAME
      WRITE(*,*)
   END IF
   CALL FLL_PRINT(PNODE, IOUNIT, POS, FPAR)
!
! IF NODE HAS CHILDREN PRINT THEM TOO
!
   IF(ASSOCIATED(PCHILD))CALL FLL_CAT_RECURSIVE_NODE(PCHILD,IOUNIT,POS,FPAR)

   FPAR%SUCCESS = .TRUE.

   RETURN
   END SUBROUTINE FLL_CAT
!
!  print node recursively
!
  RECURSIVE SUBROUTINE FLL_CAT_RECURSIVE_NODE(PNODE,IOUNIT,POS,FPAR)
!
! Description: Module prints the short content of PNODE to IOUNIT
!
! External Modules used
!   
     USE FLL_TYPE_M
     IMPLICIT NONE
!
! Declarations
!
! Arguments description
! Name         In/Out     Function
! PNODE        In         pointer to be printed
! IOUNIR       In         pointer which is to be copied
! PARENT       In         parameter, if .TRUE. write information about PNODE parent node
! FPAR         In/Out     structure containing function specific data
!
! Arguments declaration
!
    TYPE(DNODE), POINTER  :: PNODE
    TYPE(FUNC_DATA_SET) :: FPAR
    INTEGER(LINT) :: POS 
    INTEGER :: IOUNIT
!
!  Local variables
!   
    TYPE(DNODE), POINTER  :: PCURR, PNEXT, PCHILD
!
!  IF NODE HAS CHILDREN
!
    POS = POS + 1
    PCURR => PNODE
!
!  IF CHILDREN, PRINT THEM TOO
!
    DO WHILE(ASSOCIATED(PCURR))

       CALL FLL_PRINT(PCURR, IOUNIT, POS, FPAR)

       PNEXT  => PCURR%PNEXT
       PCHILD => PCURR%PCHILD
       IF(ASSOCIATED(PCHILD))THEN
         CALL FLL_CAT_RECURSIVE_NODE(PCHILD,IOUNIT,POS,FPAR)
       END IF
       
       PCURR => PNEXT
    END DO
    
    POS = POS - 1 
    
    FPAR%SUCCESS = .TRUE.
    RETURN

  END SUBROUTINE FLL_CAT_RECURSIVE_NODE
!
!  FREE MEMORY FOR NODE
!
  SUBROUTINE FLL_PRINT(PNODE, IOUNIT, POS, FPAR)
!
! Description: print content of PNODE
!
! External Modules used
!
    USE FLL_TYPE_M
    IMPLICIT NONE
!
! Declarations
!
! Arguments description
! Name         In/Out     Function
! PNODE        In         pointer to be printed
! IOUNIR       In         pointer which is to be copied
! PARENT       In         parameter, if .TRUE. write information about PNODE parent node
! FPAR         In/Out     structure containing function specific data
! POS          In         level in linked list
!
! Arguments declaration
!
   TYPE(DNODE), POINTER  :: PNODE
   TYPE(FUNC_DATA_SET) :: FPAR
   INTEGER :: IOUNIT
   INTEGER(LINT) :: POS
!
!  Local variables
!
   INTEGER(LINT) :: I,J,NDIM,NSIZE
   LOGICAL :: SAVED
   CHARACTER*2048 :: TEXT,TEXT1
   CHARACTER*72 :: NDSTR,NSSTR
   CHARACTER(3*POS) SPACE
   
   SAVED = .FALSE.
   
   NDIM = PNODE%NDIM
   NSIZE = PNODE%NSIZE
   SPACE(:) = ' '
!
!   print headers
!
     WRITE(NDSTR,'(I10)')PNODE%NDIM
     WRITE(NSSTR,'(I10)')PNODE%NSIZE

     IF(TRIM(PNODE%LTYPE) == 'DIR')THEN
        WRITE(TEXT1,*)"-",TRIM(PNODE%LTYPE),"-   ",TRIM(ADJUSTL(NDSTR)),'\        ',SPACE,TRIM(PNODE%LNAME)
        WRITE(IOUNIT, *)TRIM(TEXT1)
        RETURN
     ELSE IF(TRIM(PNODE%LTYPE) == 'N')THEN
        WRITE(TEXT1,*)"-",TRIM(PNODE%LTYPE),"-     ",TRIM(ADJUSTL(NDSTR)),'\        ',SPACE,TRIM(PNODE%LNAME)
        WRITE(IOUNIT, *)TRIM(TEXT1)
        RETURN
     ELSE 
        WRITE(TEXT1,*)"-",TRIM(PNODE%LTYPE),"-     ",TRIM(ADJUSTL(NDSTR)),'x',TRIM(ADJUSTL(NSSTR)),'      ',SPACE,TRIM(PNODE%LNAME)
     END IF
!
!  print 1D arrays
!
     IF(ASSOCIATED(PNODE%R1))THEN
       WRITE(TEXT,*)"     ",SPACE,(PNODE%R1(I), I = 1,MIN(NDIM,3_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%D1))THEN
       WRITE(TEXT,*)" ",(PNODE%D1(I), I = 1,MIN(NDIM,3_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%I1))THEN
       WRITE(TEXT,*)"     ",SPACE,(PNODE%I1(I), I = 1,MIN(NDIM,3_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%L1))THEN
       WRITE(TEXT,*)"     ",SPACE,(PNODE%L1(I), I = 1,MIN(NDIM,3_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%S1))THEN
       WRITE(TEXT,*)"     ",SPACE,(TRIM(PNODE%S1(I)), I = 1,MIN(NDIM,3_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
!
!  print 2D arrays
!
     ELSE IF(ASSOCIATED(PNODE%R2))THEN
       WRITE(TEXT,*)"     ",SPACE,((PNODE%R2(I,J), J = 1,MIN(NSIZE,2_LINT)), I=1,MIN(NDIM,2_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%D2))THEN
       WRITE(TEXT,*)"     ",SPACE,((PNODE%D2(I,J), J = 1,MIN(NSIZE,2_LINT)), I=1,MIN(NDIM,2_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%I2))THEN
       WRITE(TEXT,*)"     ",SPACE,((PNODE%I2(I,J), J = 1,MIN(NSIZE,2_LINT)), I=1,MIN(NDIM,2_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%L2))THEN
       WRITE(TEXT,*)"     ",SPACE,((PNODE%L2(I,J), J = 1,MIN(NSIZE,2_LINT)), I=1,MIN(NDIM,2_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     ELSE IF(ASSOCIATED(PNODE%S2))THEN
       WRITE(TEXT,*)"     ",SPACE,((TRIM(PNODE%S2(I,J)), J = 1,MIN(NSIZE,2_LINT)), I=1,MIN(NDIM,2_LINT))
       WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
       SAVED = .TRUE.
     END IF
!
!  if not 1D or 2D arrays, print constants
!  only for nodes which contain something
!
     IF(.NOT.SAVED)THEN
       IF(NDIM /= 0 .AND. NSIZE /= 0)THEN
         SELECT CASE(PNODE%LTYPE)
          CASE('R')
            WRITE(TEXT,*)"     ",SPACE,PNODE%R0
            WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)
          CASE('D')
            WRITE(TEXT,*)"     ",SPACE,PNODE%D0
            WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)         
         CASE('I')
            WRITE(TEXT,*)"     ",SPACE,PNODE%I0
            WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)  
          CASE('L')
            WRITE(TEXT,*)"     ",SPACE,PNODE%L0
            WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT)  
         CASE('S')
            WRITE(TEXT,*)"     ",SPACE,TRIM(PNODE%S0)
            WRITE(IOUNIT, *)TRIM(TEXT1),TRIM(TEXT) 
           CASE DEFAULT 
        
          END SELECT

       ELSE
         SELECT CASE(PNODE%LTYPE)
          CASE('R')
            WRITE(IOUNIT, *)TRIM(TEXT1)
          CASE('D')
            WRITE(IOUNIT, *)TRIM(TEXT1)
         CASE('I')
            WRITE(IOUNIT, *)TRIM(TEXT1)
         CASE('L')
            WRITE(IOUNIT, *)TRIM(TEXT1)
         CASE('S')
            WRITE(IOUNIT, *)TRIM(TEXT1)
         CASE DEFAULT 
        
         END SELECT

       END IF
     END IF
       
     RETURN

   END SUBROUTINE FLL_PRINT
 

END MODULE FLL_CAT_M
