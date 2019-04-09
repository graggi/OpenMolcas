!***********************************************************************
! This file is part of OpenMolcas.                                     *
!                                                                      *
! OpenMolcas is free software; you can redistribute it and/or modify   *
! it under the terms of the GNU Lesser General Public License, v. 2.1. *
! OpenMolcas is distributed in the hope that it will be useful, but it *
! is provided "as is" and without any express or implied warranties.   *
! For more details see the full text of the license in the file        *
! LICENSE or in <http://www.gnu.org/licenses/>.                        *
!                                                                      *
! Copyright (C) 2019, Gerardo Raggi                                    *
!***********************************************************************
        SUBROUTINE kernels(iter,nInter)
            use globvar
            integer i,z,j,iter,nInter,lm
            real*8 tpgh(3,int(lb(3)))!tpred(npx,int(lb(3))), tgrad(npx,int(lb(3)))!, thess(nInter,npx,int(lb(3)))
            m_t=iter*(1+nInter)
            ! If (allocated(full_R)) Then
            !    deallocate (full_R,rl,dl,mat,Iden)
            !    deallocate (kv,pred,gpred,hpred,var,sigma,cv,lh,l)
            ! Else
            write(6,*) 'Allocating Kernels'
                allocate (full_R(m_t,m_t))
                allocate (rl(iter,iter),dl(iter,iter), &
                            mat(iter,iter),Iden(iter,iter))
                allocate (kv(m_t),pred(npx),gpred(npx),hpred(npx),var(npx), &
                        sigma(npx),cv(m_t,npx,nInter), &
                        l(nInter),ll(3,int(lb(3))))
            ! Endif
            call miden(iter)
            z=int(lb(3))
            Write (6,*) 'Kernels l', z
            ! do j = 1,nInter
            !     do i = 1,z
            !         l(j)=lb(1)+(i-1)*(lb(2)-lb(1))/(lb(3)-1) !
            !     enddo
            ! enddo
            do j = 1,nInter
                do i = 1,z
                    l(j)=lb(1)+(i-1)*(lb(2)-lb(1))/(lb(3)-1)
                    call covarmatrix(iter,nInter)
                    call k(iter)
                    call covarvector(0,iter,nInter) ! for: 0-GEK, 1-Gradient of GEK, 2-Hessian of GEK
                    write(6,*) "Predicted GEK "
                    call predict(0,iter,nInter)
                    ll(1,i)=lh
                    tpgh(1,i)=pred(npx)
                    call covarvector(1,iter,nInter)
                    write(6,*) "Predicted Gradient of GEK"
                    call predict(1,iter,nInter)
                    ll(2,i)=lh
                    tpgh(2,i)=pred(npx)
                    ! call covarvector(2,iter,nInter)
                    ! write(6,*) "Predicted Hessian of GEK"
                    ! call predict(2,iter,nInter)
                    ! ll(3,z)=lh
                enddo
            enddo
            lm=MaxLoc(abs(ll(1,:)),dim=nInter)
            pred(npx)=tpgh(1,lm)
            Write(6,*) 'Likelihood function pred',lm,pred(npx)
            lm=MaxLoc(abs(ll(2,:)),dim=nInter)
            gpred(npx)=tpgh(2,lm)
            Write(6,*) 'Likelihood function gpred',lm,gpred(npx)
        END

        subroutine miden(iter)
            use globvar
            integer j,iter
            iden=0
            forall(j=1:iter) iden(j,j)=1
        end subroutine