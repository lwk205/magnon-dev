! This file is copied and modified from QUANTUM ESPRESSO
! Kun Cao, Henry Lambert, Feliciano Giustino
 
! Copyright (C) 2001-2003 PWSCF group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!
!-----------------------------------------------------------------------
subroutine allocate_phq
  !-----------------------------------------------------------------------
  !
  ! dynamical allocation of arrays: quantities needed for the linear
  ! response problem
  !

  USE kinds, only : DP
  USE ions_base, ONLY : nat, ntyp => nsp
  USE klist, only : nks
  USE wvfct, ONLY : nbnd, igk, npwx
  USE gvect, ONLY : ngm
  USE lsda_mod, ONLY : nspin
  USE noncollin_module, ONLY : noncolin, npol, nspin_mag
  USE fft_base, ONLY : dfftp
  USE wavefunctions_module,  ONLY: evc
  USE spin_orb, ONLY : lspinorb
  USE becmod, ONLY: bec_type, becp, allocate_bec_type
  USE uspp, ONLY: okvan, nkb
  USE paw_variables, ONLY : okpaw
  USE uspp_param, ONLY: nhm

  USE qpoint, ONLY : nksq, eigqts, igkq
  USE phus, ONLY : int1, int1_nc, int2, int2_so, int3, int3_nc, int3_paw, &
                   int4, int4_nc, int5, int5_so, becsumort, dpqq, &
                   dpqq_so, alphasum, alphasum_nc, becsum_nc, &
                   becp1, alphap
  USE efield_mod, ONLY : zstareu, zstareu0, zstarue0, zstarue0_rec, zstarue
  USE eqv, ONLY : dpsi, evq, vlocq, dmuxc, dvpsi, eprec,dpsi0,dvpsi0
  USE units_ph, ONLY : this_pcxpsi_is_on_file, this_dvkb3_is_on_file
  USE dynmat, ONLY : dyn00, dyn, dyn_rec, w2
  USE modes, ONLY : u, rtau, npert, name_rap_mode, num_rap_mode
  USE control_ph, ONLY :  lgamma, reduce_io, niter_ph


  implicit none
  INTEGER :: ik, ipol
  !
  !  allocate space for the quantities needed in the phonon program
  !
  !HL
  !lgamma=.false.
  if (lgamma) then
     !
     !  q=0  : evq and igkq are pointers to evc and igk
     !
     evq  => evc
     igkq => igk
  else
     !
     !  q!=0 : evq, igkq are allocated and calculated at point k+q
     !
     allocate (evq ( npwx*npol , nbnd))
     allocate (igkq ( npwx))
  endif
  !
  IF(reduce_io .and. niter_ph>1)then
  allocate (dvpsi0 ( npwx*npol , nbnd, nksq))
  allocate (dpsi0 ( npwx*npol , nbnd, nksq))
  END IF
  allocate ( dpsi ( npwx*npol , nbnd))
  allocate (dvpsi ( npwx*npol , nbnd))
 
 ! allocate ( dpsip ( npwx*npol , nbnd))
 ! allocate ( dpsim ( npwx*npol , nbnd))
  !
  allocate (vlocq ( ngm , ntyp))
  allocate (dmuxc ( dfftp%nnr , nspin_mag , nspin_mag))
  allocate (eprec ( nbnd, nksq) )
  !
  allocate (eigqts ( nat))
  allocate (rtau ( 3, 48, nat))
  allocate (u ( 3 * nat, 3 * nat))
  allocate (dyn ( 3 * nat, 3 * nat))
  allocate (dyn_rec ( 3 * nat, 3 * nat))
  allocate (dyn00 ( 3 * nat, 3 * nat))
  allocate (w2 ( 3 * nat))
  allocate (name_rap_mode( 3 * nat))
  allocate (num_rap_mode( 3 * nat ))
  allocate (npert ( 3 * nat))
  allocate (zstareu (3, 3,  nat))
  allocate (zstareu0 (3, 3 * nat))
  allocate (zstarue (3 , nat, 3))
  allocate (zstarue0 (3 * nat, 3))
  allocate (zstarue0_rec (3 * nat, 3))
  name_rap_mode=' '
  zstarue=0.0_DP
  zstareu0=(0.0_DP,0.0_DP)
  zstarue0=(0.0_DP,0.0_DP)
  zstarue0_rec=(0.0_DP,0.0_DP)
  if (okvan) then
     if (okpaw) then
        allocate (becsumort ( nhm*(nhm+1)/2 , nat , nspin, 3*nat))
     endif
     allocate (dpqq( nhm, nhm, 3, ntyp))
     IF (noncolin) THEN
        ALLOCATE(becsum_nc( nhm*(nhm+1)/2, nat, npol, npol))
        IF (lspinorb) THEN
           allocate(dpqq_so( nhm, nhm, nspin, 3, ntyp))
        END IF
     END IF
  endif
  allocate (this_pcxpsi_is_on_file(nksq,3))
  this_pcxpsi_is_on_file(:,:)=.false.

  ALLOCATE (becp1(nksq))
  ALLOCATE (alphap(3,nksq))
  DO ik=1,nksq
     call allocate_bec_type ( nkb, nbnd, becp1(ik) )
     DO ipol=1,3
        call allocate_bec_type ( nkb, nbnd, alphap(ipol,ik) )
     ENDDO
  END DO
  CALL allocate_bec_type ( nkb, nbnd, becp )
  return
end subroutine allocate_phq
