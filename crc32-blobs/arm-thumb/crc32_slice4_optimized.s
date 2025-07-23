
crc32_slice4_optimized.elf:     file format elf32-littlearm


Disassembly of section .text:

00000000 <init_crc32-0x4>:
       0:	be00be00 	cdplt	14, 0, cr11, cr0, cr0, {0}

00000004 <init_crc32>:
       4:	2000      	movs	r0, #0
       6:	4770      	bx	lr

00000008 <uninit_crc32>:
       8:	2000      	movs	r0, #0
       a:	4770      	bx	lr

0000000c <calculate_crc32>:
       c:	f000 b804 	b.w	18 <crc32_slice4_fast>

00000010 <sector_crc32>:
      10:	2200      	movs	r2, #0
      12:	f000 b801 	b.w	18 <crc32_slice4_fast>
      16:	bf00      	nop

00000018 <crc32_slice4_fast>:
      18:	4603      	mov	r3, r0
      1a:	4610      	mov	r0, r2
      1c:	b901      	cbnz	r1, 20 <crc32_slice4_fast+0x8>
      1e:	4770      	bx	lr
      20:	e92d 4ff0 	stmdb	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
      24:	460e      	mov	r6, r1
      26:	4619      	mov	r1, r3
      28:	43d3      	mvns	r3, r2
      2a:	078a      	lsls	r2, r1, #30
      2c:	b085      	sub	sp, #20
      2e:	f040 81c7 	bne.w	3c0 <crc32_slice4_fast+0x3a8>
      32:	2e03      	cmp	r6, #3
      34:	f240 81aa 	bls.w	38c <crc32_slice4_fast+0x374>
      38:	0972      	lsrs	r2, r6, #5
      3a:	ea4f 0b96 	mov.w	fp, r6, lsr #2
      3e:	f000 81b5 	beq.w	3ac <crc32_slice4_fast+0x394>
      42:	eb01 1e42 	add.w	lr, r1, r2, lsl #5
      46:	e9cd b602 	strd	fp, r6, [sp, #8]
      4a:	f8cd e004 	str.w	lr, [sp, #4]
      4e:	4dd8      	ldr	r5, [pc, #864]	@ (3b0 <crc32_slice4_fast+0x398>)
      50:	4cd8      	ldr	r4, [pc, #864]	@ (3b4 <crc32_slice4_fast+0x39c>)
      52:	48d9      	ldr	r0, [pc, #868]	@ (3b8 <crc32_slice4_fast+0x3a0>)
      54:	f8df e364 	ldr.w	lr, [pc, #868]	@ 3bc <crc32_slice4_fast+0x3a4>
      58:	680f      	ldr	r7, [r1, #0]
      5a:	f8d1 800c 	ldr.w	r8, [r1, #12]
      5e:	e9d1 a901 	ldrd	sl, r9, [r1, #4]
      62:	407b      	eors	r3, r7
      64:	fa5f f68a 	uxtb.w	r6, sl
      68:	ea4f 671a 	mov.w	r7, sl, lsr #24
      6c:	f854 2026 	ldr.w	r2, [r4, r6, lsl #2]
      70:	f855 6027 	ldr.w	r6, [r5, r7, lsl #2]
      74:	fa5f f789 	uxtb.w	r7, r9
      78:	4072      	eors	r2, r6
      7a:	f854 6027 	ldr.w	r6, [r4, r7, lsl #2]
      7e:	ea4f 6719 	mov.w	r7, r9, lsr #24
      82:	4072      	eors	r2, r6
      84:	f855 6027 	ldr.w	r6, [r5, r7, lsl #2]
      88:	fa5f f788 	uxtb.w	r7, r8
      8c:	4072      	eors	r2, r6
      8e:	f854 6027 	ldr.w	r6, [r4, r7, lsl #2]
      92:	ea4f 6718 	mov.w	r7, r8, lsr #24
      96:	3120      	adds	r1, #32
      98:	4072      	eors	r2, r6
      9a:	f855 6027 	ldr.w	r6, [r5, r7, lsl #2]
      9e:	f891 f000 	pld	[r1]
      a2:	e951 7c04 	ldrd	r7, ip, [r1, #-16]
      a6:	fa5f fb87 	uxtb.w	fp, r7
      aa:	4072      	eors	r2, r6
      ac:	f851 7c10 	ldr.w	r7, [r1, #-16]
      b0:	f854 602b 	ldr.w	r6, [r4, fp, lsl #2]
      b4:	4072      	eors	r2, r6
      b6:	0e3e      	lsrs	r6, r7, #24
      b8:	fa5f fb8c 	uxtb.w	fp, ip
      bc:	f855 7026 	ldr.w	r7, [r5, r6, lsl #2]
      c0:	f854 602b 	ldr.w	r6, [r4, fp, lsl #2]
      c4:	407a      	eors	r2, r7
      c6:	ea4f 6b1c 	mov.w	fp, ip, lsr #24
      ca:	f851 7c08 	ldr.w	r7, [r1, #-8]
      ce:	4072      	eors	r2, r6
      d0:	f855 602b 	ldr.w	r6, [r5, fp, lsl #2]
      d4:	fa5f fb87 	uxtb.w	fp, r7
      d8:	4072      	eors	r2, r6
      da:	f854 b02b 	ldr.w	fp, [r4, fp, lsl #2]
      de:	f851 6c04 	ldr.w	r6, [r1, #-4]
      e2:	ea82 020b 	eor.w	r2, r2, fp
      e6:	ea4f 6b17 	mov.w	fp, r7, lsr #24
      ea:	f855 b02b 	ldr.w	fp, [r5, fp, lsl #2]
      ee:	ea82 020b 	eor.w	r2, r2, fp
      f2:	fa5f fb86 	uxtb.w	fp, r6
      f6:	f854 b02b 	ldr.w	fp, [r4, fp, lsl #2]
      fa:	ea82 020b 	eor.w	r2, r2, fp
      fe:	ea4f 6b16 	mov.w	fp, r6, lsr #24
     102:	f855 b02b 	ldr.w	fp, [r5, fp, lsl #2]
     106:	ea82 020b 	eor.w	r2, r2, fp
     10a:	fa5f fb83 	uxtb.w	fp, r3
     10e:	f854 b02b 	ldr.w	fp, [r4, fp, lsl #2]
     112:	ea82 020b 	eor.w	r2, r2, fp
     116:	ea4f 6b13 	mov.w	fp, r3, lsr #24
     11a:	f855 b02b 	ldr.w	fp, [r5, fp, lsl #2]
     11e:	ea82 020b 	eor.w	r2, r2, fp
     122:	f3ca 2b07 	ubfx	fp, sl, #8, #8
     126:	f3ca 4a07 	ubfx	sl, sl, #16, #8
     12a:	f850 b02b 	ldr.w	fp, [r0, fp, lsl #2]
     12e:	ea82 0b0b 	eor.w	fp, r2, fp
     132:	f85e 202a 	ldr.w	r2, [lr, sl, lsl #2]
     136:	ea8b 0a02 	eor.w	sl, fp, r2
     13a:	f3c9 2b07 	ubfx	fp, r9, #8, #8
     13e:	f3c9 4907 	ubfx	r9, r9, #16, #8
     142:	f850 202b 	ldr.w	r2, [r0, fp, lsl #2]
     146:	f85e b029 	ldr.w	fp, [lr, r9, lsl #2]
     14a:	f3c8 2907 	ubfx	r9, r8, #8, #8
     14e:	ea8a 0a02 	eor.w	sl, sl, r2
     152:	ea8a 020b 	eor.w	r2, sl, fp
     156:	f3c8 4807 	ubfx	r8, r8, #16, #8
     15a:	f850 a029 	ldr.w	sl, [r0, r9, lsl #2]
     15e:	ea82 0b0a 	eor.w	fp, r2, sl
     162:	f85e 2028 	ldr.w	r2, [lr, r8, lsl #2]
     166:	f851 8c10 	ldr.w	r8, [r1, #-16]
     16a:	f3c8 2a07 	ubfx	sl, r8, #8, #8
     16e:	ea8b 0902 	eor.w	r9, fp, r2
     172:	f851 bc10 	ldr.w	fp, [r1, #-16]
     176:	f850 202a 	ldr.w	r2, [r0, sl, lsl #2]
     17a:	f3cb 4807 	ubfx	r8, fp, #16, #8
     17e:	ea89 0902 	eor.w	r9, r9, r2
     182:	f3cc 2207 	ubfx	r2, ip, #8, #8
     186:	f85e a028 	ldr.w	sl, [lr, r8, lsl #2]
     18a:	f850 8022 	ldr.w	r8, [r0, r2, lsl #2]
     18e:	f3cc 4c07 	ubfx	ip, ip, #16, #8
     192:	f3c7 2207 	ubfx	r2, r7, #8, #8
     196:	ea89 0b0a 	eor.w	fp, r9, sl
     19a:	f3c7 4707 	ubfx	r7, r7, #16, #8
     19e:	f85e a02c 	ldr.w	sl, [lr, ip, lsl #2]
     1a2:	f850 c022 	ldr.w	ip, [r0, r2, lsl #2]
     1a6:	f85e 7027 	ldr.w	r7, [lr, r7, lsl #2]
     1aa:	ea8b 0908 	eor.w	r9, fp, r8
     1ae:	ea89 0b0a 	eor.w	fp, r9, sl
     1b2:	f3c6 2807 	ubfx	r8, r6, #8, #8
     1b6:	ea8b 020c 	eor.w	r2, fp, ip
     1ba:	407a      	eors	r2, r7
     1bc:	f3c6 4607 	ubfx	r6, r6, #16, #8
     1c0:	f850 7028 	ldr.w	r7, [r0, r8, lsl #2]
     1c4:	f85e 6026 	ldr.w	r6, [lr, r6, lsl #2]
     1c8:	f8dd 9004 	ldr.w	r9, [sp, #4]
     1cc:	407a      	eors	r2, r7
     1ce:	f3c3 2707 	ubfx	r7, r3, #8, #8
     1d2:	f3c3 4307 	ubfx	r3, r3, #16, #8
     1d6:	4072      	eors	r2, r6
     1d8:	f850 6027 	ldr.w	r6, [r0, r7, lsl #2]
     1dc:	f85e 3023 	ldr.w	r3, [lr, r3, lsl #2]
     1e0:	4072      	eors	r2, r6
     1e2:	4549      	cmp	r1, r9
     1e4:	ea83 0302 	eor.w	r3, r3, r2
     1e8:	f47f af36 	bne.w	58 <crc32_slice4_fast+0x40>
     1ec:	e9dd b602 	ldrd	fp, r6, [sp, #8]
     1f0:	f01b 0107 	ands.w	r1, fp, #7
     1f4:	f000 80c2 	beq.w	37c <crc32_slice4_fast+0x364>
     1f8:	f8dd e004 	ldr.w	lr, [sp, #4]
     1fc:	4c6c      	ldr	r4, [pc, #432]	@ (3b0 <crc32_slice4_fast+0x398>)
     1fe:	f8de 2000 	ldr.w	r2, [lr]
     202:	f8df a1b0 	ldr.w	sl, [pc, #432]	@ 3b4 <crc32_slice4_fast+0x39c>
     206:	f8df 91b0 	ldr.w	r9, [pc, #432]	@ 3b8 <crc32_slice4_fast+0x3a0>
     20a:	405a      	eors	r2, r3
     20c:	0e10      	lsrs	r0, r2, #24
     20e:	b2d7      	uxtb	r7, r2
     210:	f854 3020 	ldr.w	r3, [r4, r0, lsl #2]
     214:	f85a 5027 	ldr.w	r5, [sl, r7, lsl #2]
     218:	4f68      	ldr	r7, [pc, #416]	@ (3bc <crc32_slice4_fast+0x3a4>)
     21a:	f3c2 2007 	ubfx	r0, r2, #8, #8
     21e:	f3c2 4c07 	ubfx	ip, r2, #16, #8
     222:	f859 2020 	ldr.w	r2, [r9, r0, lsl #2]
     226:	406b      	eors	r3, r5
     228:	f857 502c 	ldr.w	r5, [r7, ip, lsl #2]
     22c:	4053      	eors	r3, r2
     22e:	f016 0f18 	tst.w	r6, #24
     232:	ea83 0305 	eor.w	r3, r3, r5
     236:	f000 80a1 	beq.w	37c <crc32_slice4_fast+0x364>
     23a:	f8de 0004 	ldr.w	r0, [lr, #4]
     23e:	fa5f f880 	uxtb.w	r8, r0
     242:	0e02      	lsrs	r2, r0, #24
     244:	f85a c028 	ldr.w	ip, [sl, r8, lsl #2]
     248:	f854 5022 	ldr.w	r5, [r4, r2, lsl #2]
     24c:	ea8c 0205 	eor.w	r2, ip, r5
     250:	f3c0 2507 	ubfx	r5, r0, #8, #8
     254:	f3c0 4007 	ubfx	r0, r0, #16, #8
     258:	f859 8025 	ldr.w	r8, [r9, r5, lsl #2]
     25c:	f857 c020 	ldr.w	ip, [r7, r0, lsl #2]
     260:	ea82 0208 	eor.w	r2, r2, r8
     264:	ea82 050c 	eor.w	r5, r2, ip
     268:	2902      	cmp	r1, #2
     26a:	ea83 0305 	eor.w	r3, r3, r5
     26e:	f240 8085 	bls.w	37c <crc32_slice4_fast+0x364>
     272:	f8de 0008 	ldr.w	r0, [lr, #8]
     276:	0e05      	lsrs	r5, r0, #24
     278:	fa5f f880 	uxtb.w	r8, r0
     27c:	f854 c025 	ldr.w	ip, [r4, r5, lsl #2]
     280:	f85a 2028 	ldr.w	r2, [sl, r8, lsl #2]
     284:	f3c0 2507 	ubfx	r5, r0, #8, #8
     288:	f3c0 4007 	ubfx	r0, r0, #16, #8
     28c:	f859 8025 	ldr.w	r8, [r9, r5, lsl #2]
     290:	ea82 020c 	eor.w	r2, r2, ip
     294:	f857 c020 	ldr.w	ip, [r7, r0, lsl #2]
     298:	ea82 0208 	eor.w	r2, r2, r8
     29c:	ea82 050c 	eor.w	r5, r2, ip
     2a0:	f01b 0f04 	tst.w	fp, #4
     2a4:	ea83 0305 	eor.w	r3, r3, r5
     2a8:	d068      	beq.n	37c <crc32_slice4_fast+0x364>
     2aa:	f8de 000c 	ldr.w	r0, [lr, #12]
     2ae:	0e02      	lsrs	r2, r0, #24
     2b0:	46f3      	mov	fp, lr
     2b2:	fa5f fe80 	uxtb.w	lr, r0
     2b6:	f854 c022 	ldr.w	ip, [r4, r2, lsl #2]
     2ba:	f85a 802e 	ldr.w	r8, [sl, lr, lsl #2]
     2be:	f3c0 2207 	ubfx	r2, r0, #8, #8
     2c2:	f3c0 4007 	ubfx	r0, r0, #16, #8
     2c6:	f859 e022 	ldr.w	lr, [r9, r2, lsl #2]
     2ca:	ea88 050c 	eor.w	r5, r8, ip
     2ce:	f857 8020 	ldr.w	r8, [r7, r0, lsl #2]
     2d2:	ea85 050e 	eor.w	r5, r5, lr
     2d6:	ea85 0208 	eor.w	r2, r5, r8
     2da:	2904      	cmp	r1, #4
     2dc:	ea83 0302 	eor.w	r3, r3, r2
     2e0:	d94c      	bls.n	37c <crc32_slice4_fast+0x364>
     2e2:	f8db c010 	ldr.w	ip, [fp, #16]
     2e6:	fa5f f08c 	uxtb.w	r0, ip
     2ea:	ea4f 621c 	mov.w	r2, ip, lsr #24
     2ee:	f85a 5020 	ldr.w	r5, [sl, r0, lsl #2]
     2f2:	f854 e022 	ldr.w	lr, [r4, r2, lsl #2]
     2f6:	ea85 000e 	eor.w	r0, r5, lr
     2fa:	f3cc 2507 	ubfx	r5, ip, #8, #8
     2fe:	f3cc 4807 	ubfx	r8, ip, #16, #8
     302:	f859 e025 	ldr.w	lr, [r9, r5, lsl #2]
     306:	f857 c028 	ldr.w	ip, [r7, r8, lsl #2]
     30a:	ea80 020e 	eor.w	r2, r0, lr
     30e:	ea82 000c 	eor.w	r0, r2, ip
     312:	2905      	cmp	r1, #5
     314:	ea83 0300 	eor.w	r3, r3, r0
     318:	d030      	beq.n	37c <crc32_slice4_fast+0x364>
     31a:	f8db 5014 	ldr.w	r5, [fp, #20]
     31e:	0e2a      	lsrs	r2, r5, #24
     320:	fa5f fe85 	uxtb.w	lr, r5
     324:	f854 c022 	ldr.w	ip, [r4, r2, lsl #2]
     328:	f85a 802e 	ldr.w	r8, [sl, lr, lsl #2]
     32c:	f3c5 2207 	ubfx	r2, r5, #8, #8
     330:	f3c5 4507 	ubfx	r5, r5, #16, #8
     334:	f859 e022 	ldr.w	lr, [r9, r2, lsl #2]
     338:	ea88 000c 	eor.w	r0, r8, ip
     33c:	f857 8025 	ldr.w	r8, [r7, r5, lsl #2]
     340:	ea80 000e 	eor.w	r0, r0, lr
     344:	ea80 0208 	eor.w	r2, r0, r8
     348:	2907      	cmp	r1, #7
     34a:	ea83 0302 	eor.w	r3, r3, r2
     34e:	d115      	bne.n	37c <crc32_slice4_fast+0x364>
     350:	f8db b018 	ldr.w	fp, [fp, #24]
     354:	fa5f f58b 	uxtb.w	r5, fp
     358:	ea4f 601b 	mov.w	r0, fp, lsr #24
     35c:	f85a 2025 	ldr.w	r2, [sl, r5, lsl #2]
     360:	f854 4020 	ldr.w	r4, [r4, r0, lsl #2]
     364:	f3cb 2507 	ubfx	r5, fp, #8, #8
     368:	4062      	eors	r2, r4
     36a:	f3cb 4407 	ubfx	r4, fp, #16, #8
     36e:	f859 0025 	ldr.w	r0, [r9, r5, lsl #2]
     372:	f857 7024 	ldr.w	r7, [r7, r4, lsl #2]
     376:	4042      	eors	r2, r0
     378:	407a      	eors	r2, r7
     37a:	4053      	eors	r3, r2
     37c:	f8dd a004 	ldr.w	sl, [sp, #4]
     380:	f016 0603 	ands.w	r6, r6, #3
     384:	eb0a 0181 	add.w	r1, sl, r1, lsl #2
     388:	f000 808e 	beq.w	4a8 <crc32_slice4_fast+0x490>
     38c:	780a      	ldrb	r2, [r1, #0]
     38e:	f8df 9020 	ldr.w	r9, [pc, #32]	@ 3b0 <crc32_slice4_fast+0x398>
     392:	405a      	eors	r2, r3
     394:	b2d5      	uxtb	r5, r2
     396:	2e01      	cmp	r6, #1
     398:	f859 c025 	ldr.w	ip, [r9, r5, lsl #2]
     39c:	ea8c 2013 	eor.w	r0, ip, r3, lsr #8
     3a0:	f040 8084 	bne.w	4ac <crc32_slice4_fast+0x494>
     3a4:	43c0      	mvns	r0, r0
     3a6:	b005      	add	sp, #20
     3a8:	e8bd 8ff0 	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
     3ac:	9101      	str	r1, [sp, #4]
     3ae:	e71f      	b.n	1f0 <crc32_slice4_fast+0x1d8>
     3b0:	000011a0 	.word	0x000011a0
     3b4:	000005a0 	.word	0x000005a0
     3b8:	000009a0 	.word	0x000009a0
     3bc:	00000da0 	.word	0x00000da0
     3c0:	1e74      	subs	r4, r6, #1
     3c2:	f014 0007 	ands.w	r0, r4, #7
     3c6:	4a74      	ldr	r2, [pc, #464]	@ (598 <crc32_slice4_fast+0x580>)
     3c8:	d064      	beq.n	494 <crc32_slice4_fast+0x47c>
     3ca:	f811 5b01 	ldrb.w	r5, [r1], #1
     3ce:	405d      	eors	r5, r3
     3d0:	b2ef      	uxtb	r7, r5
     3d2:	078d      	lsls	r5, r1, #30
     3d4:	f852 8027 	ldr.w	r8, [r2, r7, lsl #2]
     3d8:	4626      	mov	r6, r4
     3da:	ea88 2313 	eor.w	r3, r8, r3, lsr #8
     3de:	f43f ae28 	beq.w	32 <crc32_slice4_fast+0x1a>
     3e2:	2801      	cmp	r0, #1
     3e4:	d056      	beq.n	494 <crc32_slice4_fast+0x47c>
     3e6:	2802      	cmp	r0, #2
     3e8:	d047      	beq.n	47a <crc32_slice4_fast+0x462>
     3ea:	2803      	cmp	r0, #3
     3ec:	d039      	beq.n	462 <crc32_slice4_fast+0x44a>
     3ee:	2804      	cmp	r0, #4
     3f0:	d02b      	beq.n	44a <crc32_slice4_fast+0x432>
     3f2:	2805      	cmp	r0, #5
     3f4:	d01c      	beq.n	430 <crc32_slice4_fast+0x418>
     3f6:	2806      	cmp	r0, #6
     3f8:	d00d      	beq.n	416 <crc32_slice4_fast+0x3fe>
     3fa:	f811 4b01 	ldrb.w	r4, [r1], #1
     3fe:	405c      	eors	r4, r3
     400:	fa5f f984 	uxtb.w	r9, r4
     404:	078c      	lsls	r4, r1, #30
     406:	f852 a029 	ldr.w	sl, [r2, r9, lsl #2]
     40a:	f106 36ff 	add.w	r6, r6, #4294967295	@ 0xffffffff
     40e:	ea8a 2313 	eor.w	r3, sl, r3, lsr #8
     412:	f43f ae0e 	beq.w	32 <crc32_slice4_fast+0x1a>
     416:	f811 0b01 	ldrb.w	r0, [r1], #1
     41a:	4058      	eors	r0, r3
     41c:	b2c5      	uxtb	r5, r0
     41e:	0788      	lsls	r0, r1, #30
     420:	f852 b025 	ldr.w	fp, [r2, r5, lsl #2]
     424:	f106 36ff 	add.w	r6, r6, #4294967295	@ 0xffffffff
     428:	ea8b 2313 	eor.w	r3, fp, r3, lsr #8
     42c:	f43f ae01 	beq.w	32 <crc32_slice4_fast+0x1a>
     430:	f811 7b01 	ldrb.w	r7, [r1], #1
     434:	405f      	eors	r7, r3
     436:	b2fc      	uxtb	r4, r7
     438:	078f      	lsls	r7, r1, #30
     43a:	f852 c024 	ldr.w	ip, [r2, r4, lsl #2]
     43e:	f106 36ff 	add.w	r6, r6, #4294967295	@ 0xffffffff
     442:	ea8c 2313 	eor.w	r3, ip, r3, lsr #8
     446:	f43f adf4 	beq.w	32 <crc32_slice4_fast+0x1a>
     44a:	f811 0b01 	ldrb.w	r0, [r1], #1
     44e:	4058      	eors	r0, r3
     450:	b2c5      	uxtb	r5, r0
     452:	3e01      	subs	r6, #1
     454:	f852 8025 	ldr.w	r8, [r2, r5, lsl #2]
     458:	078d      	lsls	r5, r1, #30
     45a:	ea88 2313 	eor.w	r3, r8, r3, lsr #8
     45e:	f43f ade8 	beq.w	32 <crc32_slice4_fast+0x1a>
     462:	f811 7b01 	ldrb.w	r7, [r1], #1
     466:	405f      	eors	r7, r3
     468:	b2fc      	uxtb	r4, r7
     46a:	3e01      	subs	r6, #1
     46c:	f852 9024 	ldr.w	r9, [r2, r4, lsl #2]
     470:	078c      	lsls	r4, r1, #30
     472:	ea89 2313 	eor.w	r3, r9, r3, lsr #8
     476:	f43f addc 	beq.w	32 <crc32_slice4_fast+0x1a>
     47a:	f811 0b01 	ldrb.w	r0, [r1], #1
     47e:	4058      	eors	r0, r3
     480:	b2c5      	uxtb	r5, r0
     482:	0788      	lsls	r0, r1, #30
     484:	f852 a025 	ldr.w	sl, [r2, r5, lsl #2]
     488:	f106 36ff 	add.w	r6, r6, #4294967295	@ 0xffffffff
     48c:	ea8a 2313 	eor.w	r3, sl, r3, lsr #8
     490:	f43f adcf 	beq.w	32 <crc32_slice4_fast+0x1a>
     494:	780f      	ldrb	r7, [r1, #0]
     496:	405f      	eors	r7, r3
     498:	b2fc      	uxtb	r4, r7
     49a:	3e01      	subs	r6, #1
     49c:	f852 b024 	ldr.w	fp, [r2, r4, lsl #2]
     4a0:	46b4      	mov	ip, r6
     4a2:	ea8b 2313 	eor.w	r3, fp, r3, lsr #8
     4a6:	b99e      	cbnz	r6, 4d0 <crc32_slice4_fast+0x4b8>
     4a8:	43d8      	mvns	r0, r3
     4aa:	e77c      	b.n	3a6 <crc32_slice4_fast+0x38e>
     4ac:	784b      	ldrb	r3, [r1, #1]
     4ae:	4043      	eors	r3, r0
     4b0:	b2dc      	uxtb	r4, r3
     4b2:	2e02      	cmp	r6, #2
     4b4:	f859 8024 	ldr.w	r8, [r9, r4, lsl #2]
     4b8:	ea88 2010 	eor.w	r0, r8, r0, lsr #8
     4bc:	f43f af72 	beq.w	3a4 <crc32_slice4_fast+0x38c>
     4c0:	788e      	ldrb	r6, [r1, #2]
     4c2:	4046      	eors	r6, r0
     4c4:	b2f1      	uxtb	r1, r6
     4c6:	f859 b021 	ldr.w	fp, [r9, r1, lsl #2]
     4ca:	ea8b 2010 	eor.w	r0, fp, r0, lsr #8
     4ce:	e769      	b.n	3a4 <crc32_slice4_fast+0x38c>
     4d0:	3101      	adds	r1, #1
     4d2:	078f      	lsls	r7, r1, #30
     4d4:	4608      	mov	r0, r1
     4d6:	f43f adac 	beq.w	32 <crc32_slice4_fast+0x1a>
     4da:	f811 5b01 	ldrb.w	r5, [r1], #1
     4de:	405d      	eors	r5, r3
     4e0:	b2ef      	uxtb	r7, r5
     4e2:	3e01      	subs	r6, #1
     4e4:	f852 8027 	ldr.w	r8, [r2, r7, lsl #2]
     4e8:	078f      	lsls	r7, r1, #30
     4ea:	ea88 2313 	eor.w	r3, r8, r3, lsr #8
     4ee:	f43f ada0 	beq.w	32 <crc32_slice4_fast+0x1a>
     4f2:	7809      	ldrb	r1, [r1, #0]
     4f4:	4059      	eors	r1, r3
     4f6:	b2ce      	uxtb	r6, r1
     4f8:	1c81      	adds	r1, r0, #2
     4fa:	f852 9026 	ldr.w	r9, [r2, r6, lsl #2]
     4fe:	078d      	lsls	r5, r1, #30
     500:	ea89 2313 	eor.w	r3, r9, r3, lsr #8
     504:	f1ac 0602 	sub.w	r6, ip, #2
     508:	f43f ad93 	beq.w	32 <crc32_slice4_fast+0x1a>
     50c:	7884      	ldrb	r4, [r0, #2]
     50e:	405c      	eors	r4, r3
     510:	b2e5      	uxtb	r5, r4
     512:	1cc1      	adds	r1, r0, #3
     514:	f852 a025 	ldr.w	sl, [r2, r5, lsl #2]
     518:	078f      	lsls	r7, r1, #30
     51a:	ea8a 2313 	eor.w	r3, sl, r3, lsr #8
     51e:	f1ac 0603 	sub.w	r6, ip, #3
     522:	f43f ad86 	beq.w	32 <crc32_slice4_fast+0x1a>
     526:	78c7      	ldrb	r7, [r0, #3]
     528:	405f      	eors	r7, r3
     52a:	fa5f fb87 	uxtb.w	fp, r7
     52e:	0785      	lsls	r5, r0, #30
     530:	f852 802b 	ldr.w	r8, [r2, fp, lsl #2]
     534:	f1ac 0604 	sub.w	r6, ip, #4
     538:	ea88 2313 	eor.w	r3, r8, r3, lsr #8
     53c:	f100 0104 	add.w	r1, r0, #4
     540:	f43f ad77 	beq.w	32 <crc32_slice4_fast+0x1a>
     544:	7901      	ldrb	r1, [r0, #4]
     546:	4059      	eors	r1, r3
     548:	b2ce      	uxtb	r6, r1
     54a:	1d41      	adds	r1, r0, #5
     54c:	f852 9026 	ldr.w	r9, [r2, r6, lsl #2]
     550:	078f      	lsls	r7, r1, #30
     552:	ea89 2313 	eor.w	r3, r9, r3, lsr #8
     556:	f1ac 0605 	sub.w	r6, ip, #5
     55a:	f43f ad6a 	beq.w	32 <crc32_slice4_fast+0x1a>
     55e:	7944      	ldrb	r4, [r0, #5]
     560:	405c      	eors	r4, r3
     562:	b2e5      	uxtb	r5, r4
     564:	1d81      	adds	r1, r0, #6
     566:	f852 a025 	ldr.w	sl, [r2, r5, lsl #2]
     56a:	078d      	lsls	r5, r1, #30
     56c:	ea8a 2313 	eor.w	r3, sl, r3, lsr #8
     570:	f1ac 0606 	sub.w	r6, ip, #6
     574:	f43f ad5d 	beq.w	32 <crc32_slice4_fast+0x1a>
     578:	7987      	ldrb	r7, [r0, #6]
     57a:	1dc1      	adds	r1, r0, #7
     57c:	ea87 0003 	eor.w	r0, r7, r3
     580:	b2c4      	uxtb	r4, r0
     582:	f1ac 0607 	sub.w	r6, ip, #7
     586:	f852 c024 	ldr.w	ip, [r2, r4, lsl #2]
     58a:	0788      	lsls	r0, r1, #30
     58c:	ea8c 2313 	eor.w	r3, ip, r3, lsr #8
     590:	f43f ad4f 	beq.w	32 <crc32_slice4_fast+0x1a>
     594:	e77e      	b.n	494 <crc32_slice4_fast+0x47c>
     596:	bf00      	nop
     598:	000011a0 	.word	0x000011a0
     59c:	00000000 	.word	0x00000000

000005a0 <crc32_table3>:
     5a0:	00000000 b8bc6765 aa09c88b 12b5afee     ....eg..........
     5b0:	8f629757 37def032 256b5fdc 9dd738b9     W.b.2..7._k%.8..
     5c0:	c5b428ef 7d084f8a 6fbde064 d7018701     .(...O.}d..o....
     5d0:	4ad6bfb8 f26ad8dd e0df7733 58631056     ...J..j.3w..V.cX
     5e0:	5019579f e8a530fa fa109f14 42acf871     .W.P.0......q..B
     5f0:	df7bc0c8 67c7a7ad 75720843 cdce6f26     ..{....gC.ru&o..
     600:	95ad7f70 2d111815 3fa4b7fb 8718d09e     p......-...?....
     610:	1acfe827 a2738f42 b0c620ac 087a47c9     '...B.s.. ...Gz.
     620:	a032af3e 188ec85b 0a3b67b5 b28700d0     >.2.[....g;.....
     630:	2f503869 97ec5f0c 8559f0e2 3de59787     i8P/._....Y....=
     640:	658687d1 dd3ae0b4 cf8f4f5a 7733283f     ...e..:.ZO..?(3w
     650:	eae41086 525877e3 40edd80d f851bf68     .....wXR...@h.Q.
     660:	f02bf8a1 48979fc4 5a22302a e29e574f     ..+....H*0"ZOW..
     670:	7f496ff6 c7f50893 d540a77d 6dfcc018     .oI.....}.@....m
     680:	359fd04e 8d23b72b 9f9618c5 272a7fa0     N..5+.#.......*'
     690:	bafd4719 0241207c 10f48f92 a848e8f7     .G..| A.......H.
     6a0:	9b14583d 23a83f58 311d90b6 89a1f7d3     =X..X?.#...1....
     6b0:	1476cf6a accaa80f be7f07e1 06c36084     j.v..........`..
     6c0:	5ea070d2 e61c17b7 f4a9b859 4c15df3c     .p.^....Y...<..L
     6d0:	d1c2e785 697e80e0 7bcb2f0e c377486b     ......~i./.{kHw.
     6e0:	cb0d0fa2 73b168c7 6104c729 d9b8a04c     .....h.s)..aL...
     6f0:	446f98f5 fcd3ff90 ee66507e 56da371b     ..oD....~Pf..7.V
     700:	0eb9274d b6054028 a4b0efc6 1c0c88a3     M'..(@..........
     710:	81dbb01a 3967d77f 2bd27891 936e1ff4     ......g9.x.+..n.
     720:	3b26f703 839a9066 912f3f88 299358ed     ..&;f....?/..X.)
     730:	b4446054 0cf80731 1e4da8df a6f1cfba     T`D.1.....M.....
     740:	fe92dfec 462eb889 549b1767 ec277002     .......Fg..T.p'.
     750:	71f048bb c94c2fde dbf98030 6345e755     .H.q./L.0...U.Ec
     760:	6b3fa09c d383c7f9 c1366817 798a0f72     ..?k.....h6.r..y
     770:	e45d37cb 5ce150ae 4e54ff40 f6e89825     .7]..P.\@.TN%...
     780:	ae8b8873 1637ef16 048240f8 bc3e279d     s.....7..@...'>.
     790:	21e91f24 99557841 8be0d7af 335cb0ca     $..!AxU.......\3
	...

000009a0 <crc32_table2>:
     9a0:	00000000 01c26a37 0384d46e 0246be59     ....7j..n...Y.F.
     9b0:	0709a8dc 06cbc2eb 048d7cb2 054f1685     .........|....O.
     9c0:	0e1351b8 0fd13b8f 0d9785d6 0c55efe1     .Q...;........U.
     9d0:	091af964 08d89353 0a9e2d0a 0b5c473d     d...S....-..=G\.
     9e0:	1c26a370 1de4c947 1fa2771e 1e601d29     p.&.G....w..).`.
     9f0:	1b2f0bac 1aed619b 18abdfc2 1969b5f5     ../..a........i.
     a00:	1235f2c8 13f798ff 11b126a6 10734c91     ..5......&...Ls.
     a10:	153c5a14 14fe3023 16b88e7a 177ae44d     .Z<.#0..z...M.z.
     a20:	384d46e0 398f2cd7 3bc9928e 3a0bf8b9     .FM8.,.9...;...:
     a30:	3f44ee3c 3e86840b 3cc03a52 3d025065     <.D?...>R:.<eP.=
     a40:	365e1758 379c7d6f 35dac336 3418a901     X.^6o}.76..5...4
     a50:	3157bf84 3095d5b3 32d36bea 331101dd     ..W1...0.k.2...3
     a60:	246be590 25a98fa7 27ef31fe 262d5bc9     ..k$...%.1.'.[-&
     a70:	23624d4c 22a0277b 20e69922 2124f315     LMb#{'."".. ..$!
     a80:	2a78b428 2bbade1f 29fc6046 283e0a71     (.x*...+F`.)q.>(
     a90:	2d711cf4 2cb376c3 2ef5c89a 2f37a2ad     ..q-.v.,......7/
     aa0:	709a8dc0 7158e7f7 731e59ae 72dc3399     ...p..Xq.Y.s.3.r
     ab0:	7793251c 76514f2b 7417f172 75d59b45     .%.w+OQvr..tE..u
     ac0:	7e89dc78 7f4bb64f 7d0d0816 7ccf6221     x..~O.K....}!b.|
     ad0:	798074a4 78421e93 7a04a0ca 7bc6cafd     .t.y..Bx...z...{
     ae0:	6cbc2eb0 6d7e4487 6f38fade 6efa90e9     ...l.D~m..8o...n
     af0:	6bb5866c 6a77ec5b 68315202 69f33835     l..k[.wj.R1h58.i
     b00:	62af7f08 636d153f 612bab66 60e9c151     ...b?.mcf.+aQ..`
     b10:	65a6d7d4 6464bde3 662203ba 67e0698d     ...e..dd.."f.i.g
     b20:	48d7cb20 4915a117 4b531f4e 4a917579      ..H...IN.SKyu.J
     b30:	4fde63fc 4e1c09cb 4c5ab792 4d98dda5     .c.O...N..ZL...M
     b40:	46c49a98 4706f0af 45404ef6 448224c1     ...F...G.N@E.$.D
     b50:	41cd3244 400f5873 4249e62a 438b8c1d     D2.AsX.@*.IB...C
     b60:	54f16850 55330267 5775bc3e 56b7d609     Ph.Tg.3U>.uW...V
     b70:	53f8c08c 523aaabb 507c14e2 51be7ed5     ...S..:R..|P.~.Q
     b80:	5ae239e8 5b2053df 5966ed86 58a487b1     .9.Z.S [..fY...X
     b90:	5deb9134 5c29fb03 5e6f455a 5fad2f6d     4..]..)\ZEo^m/._
	...

00000da0 <crc32_table1>:
     da0:	00000000 191b3141 32366282 2b2d53c3     ....A1...b62.S-+
     db0:	646cc504 7d77f445 565aa786 4f4196c7     ..ldE.w}..ZV..AO
     dc0:	c8d98a08 d1c2bb49 faefe88a e3f4d9cb     ....I...........
     dd0:	acb54f0c b5ae7e4d 9e832d8e 87981ccf     .O..M~...-......
     de0:	4ac21251 53d92310 78f470d3 61ef4192     Q..J.#.S.p.x.A.a
     df0:	2eaed755 37b5e614 1c98b5d7 05838496     U......7........
     e00:	821b9859 9b00a918 b02dfadb a936cb9a     Y.........-...6.
     e10:	e6775d5d ff6c6c1c d4413fdf cd5a0e9e     ]]w..ll..?A...Z.
     e20:	958424a2 8c9f15e3 a7b24620 bea97761     .$...... F..aw..
     e30:	f1e8e1a6 e8f3d0e7 c3de8324 dac5b265     ........$...e...
     e40:	5d5daeaa 44469feb 6f6bcc28 7670fd69     ..]]..FD(.koi.pv
     e50:	39316bae 202a5aef 0b07092c 121c386d     .k19.Z* ,...m8..
     e60:	df4636f3 c65d07b2 ed705471 f46b6530     .6F...].qTp.0ek.
     e70:	bb2af3f7 a231c2b6 891c9175 9007a034     ..*...1.u...4...
     e80:	179fbcfb 0e848dba 25a9de79 3cb2ef38     ........y..%8..<
     e90:	73f379ff 6ae848be 41c51b7d 58de2a3c     .y.s.H.j}..A<*.X
     ea0:	f0794f05 e9627e44 c24f2d87 db541cc6     .Oy.D~b..-O...T.
     eb0:	94158a01 8d0ebb40 a623e883 bf38d9c2     ....@.....#...8.
     ec0:	38a0c50d 21bbf44c 0a96a78f 138d96ce     ...8L..!........
     ed0:	5ccc0009 45d73148 6efa628b 77e153ca     ...\H1.E.b.n.S.w
     ee0:	babb5d54 a3a06c15 888d3fd6 91960e97     T]...l...?......
     ef0:	ded79850 c7cca911 ece1fad2 f5facb93     P...............
     f00:	7262d75c 6b79e61d 4054b5de 594f849f     \.br..yk..T@..OY
     f10:	160e1258 0f152319 243870da 3d23419b     X....#...p8$.A#=
     f20:	65fd6ba7 7ce65ae6 57cb0925 4ed03864     .k.e.Z.|%..Wd8.N
     f30:	0191aea3 188a9fe2 33a7cc21 2abcfd60     ........!..3`..*
     f40:	ad24e1af b43fd0ee 9f12832d 8609b26c     ..$...?.-...l...
     f50:	c94824ab d05315ea fb7e4629 e2657768     .$H...S.)F~.hwe.
     f60:	2f3f79f6 362448b7 1d091b74 04122a35     .y?/.H$6t...5*..
     f70:	4b53bcf2 52488db3 7965de70 607eef31     ..SK..HRp.ey1.~`
     f80:	e7e6f3fe fefdc2bf d5d0917c cccba03d     ........|...=...
     f90:	838a36fa 9a9107bb b1bc5478 a8a76539     .6......xT..9e..
	...

000011a0 <crc32_table0>:
    11a0:	00000000 77073096 ee0e612c 990951ba     .....0.w,a...Q..
    11b0:	076dc419 706af48f e963a535 9e6495a3     ..m...jp5.c...d.
    11c0:	0edb8832 79dcb8a4 e0d5e91e 97d2d988     2......y........
    11d0:	09b64c2b 7eb17cbd e7b82d07 90bf1d91     +L...|.~.-......
    11e0:	1db71064 6ab020f2 f3b97148 84be41de     d.... .jHq...A..
    11f0:	1adad47d 6ddde4eb f4d4b551 83d385c7     }......mQ.......
    1200:	136c9856 646ba8c0 fd62f97a 8a65c9ec     V.l...kdz.b...e.
    1210:	14015c4f 63066cd9 fa0f3d63 8d080df5     O\...l.cc=......
    1220:	3b6e20c8 4c69105e d56041e4 a2677172     . n;^.iL.A`.rqg.
    1230:	3c03e4d1 4b04d447 d20d85fd a50ab56b     ...<G..K....k...
    1240:	35b5a8fa 42b2986c dbbbc9d6 acbcf940     ...5l..B....@...
    1250:	32d86ce3 45df5c75 dcd60dcf abd13d59     .l.2u\.E....Y=..
    1260:	26d930ac 51de003a c8d75180 bfd06116     .0.&:..Q.Q...a..
    1270:	21b4f4b5 56b3c423 cfba9599 b8bda50f     ...!#..V........
    1280:	2802b89e 5f058808 c60cd9b2 b10be924     ...(..._....$...
    1290:	2f6f7c87 58684c11 c1611dab b6662d3d     .|o/.LhX..a.=-f.
    12a0:	76dc4190 01db7106 98d220bc efd5102a     .A.v.q... ..*...
    12b0:	71b18589 06b6b51f 9fbfe4a5 e8b8d433     ...q........3...
    12c0:	7807c9a2 0f00f934 9609a88e e10e9818     ...x4...........
    12d0:	7f6a0dbb 086d3d2d 91646c97 e6635c01     ..j.-=m..ld..\c.
    12e0:	6b6b51f4 1c6c6162 856530d8 f262004e     .Qkkbal..0e.N.b.
    12f0:	6c0695ed 1b01a57b 8208f4c1 f50fc457     ...l{.......W...
    1300:	65b0d9c6 12b7e950 8bbeb8ea fcb9887c     ...eP.......|...
    1310:	62dd1ddf 15da2d49 8cd37cf3 fbd44c65     ...bI-...|..eL..
    1320:	4db26158 3ab551ce a3bc0074 d4bb30e2     Xa.M.Q.:t....0..
    1330:	4adfa541 3dd895d7 a4d1c46d d3d6f4fb     A..J...=m.......
    1340:	4369e96a 346ed9fc ad678846 da60b8d0     j.iC..n4F.g...`.
    1350:	44042d73 33031de5 aa0a4c5f dd0d7cc9     s-.D...3_L...|..
    1360:	5005713c 270241aa be0b1010 c90c2086     <q.P.A.'..... ..
    1370:	5768b525 206f85b3 b966d409 ce61e49f     %.hW..o ..f...a.
    1380:	5edef90e 29d9c998 b0d09822 c7d7a8b4     ...^...)".......
    1390:	59b33d17 2eb40d81 b7bd5c3b c0ba6cad     .=.Y....;\...l..
    13a0:	edb88320 9abfb3b6 03b6e20c 74b1d29a      ..............t
    13b0:	ead54739 9dd277af 04db2615 73dc1683     9G...w...&.....s
    13c0:	e3630b12 94643b84 0d6d6a3e 7a6a5aa8     ..c..;d.>jm..Zjz
    13d0:	e40ecf0b 9309ff9d 0a00ae27 7d079eb1     ........'......}
    13e0:	f00f9344 8708a3d2 1e01f268 6906c2fe     D.......h......i
    13f0:	f762575d 806567cb 196c3671 6e6b06e7     ]Wb..ge.q6l...kn
    1400:	fed41b76 89d32be0 10da7a5a 67dd4acc     v....+..Zz...J.g
    1410:	f9b9df6f 8ebeeff9 17b7be43 60b08ed5     o.......C......`
    1420:	d6d6a3e8 a1d1937e 38d8c2c4 4fdff252     ....~......8R..O
    1430:	d1bb67f1 a6bc5767 3fb506dd 48b2364b     .g..gW.....?K6.H
    1440:	d80d2bda af0a1b4c 36034af6 41047a60     .+..L....J.6`z.A
    1450:	df60efc3 a867df55 316e8eef 4669be79     ..`.U.g...n1y.iF
    1460:	cb61b38c bc66831a 256fd2a0 5268e236     ..a...f...o%6.hR
    1470:	cc0c7795 bb0b4703 220216b9 5505262f     .w...G....."/&.U
    1480:	c5ba3bbe b2bd0b28 2bb45a92 5cb36a04     .;..(....Z.+.j.\
    1490:	c2d7ffa7 b5d0cf31 2cd99e8b 5bdeae1d     ....1......,...[
    14a0:	9b64c2b0 ec63f226 756aa39c 026d930a     ..d.&.c...ju..m.
    14b0:	9c0906a9 eb0e363f 72076785 05005713     ....?6...g.r.W..
    14c0:	95bf4a82 e2b87a14 7bb12bae 0cb61b38     .J...z...+.{8...
    14d0:	92d28e9b e5d5be0d 7cdcefb7 0bdbdf21     ...........|!...
    14e0:	86d3d2d4 f1d4e242 68ddb3f8 1fda836e     ....B......hn...
    14f0:	81be16cd f6b9265b 6fb077e1 18b74777     ....[&...w.owG..
    1500:	88085ae6 ff0f6a70 66063bca 11010b5c     .Z..pj...;.f\...
    1510:	8f659eff f862ae69 616bffd3 166ccf45     ..e.i.b...kaE.l.
    1520:	a00ae278 d70dd2ee 4e048354 3903b3c2     x.......T..N...9
    1530:	a7672661 d06016f7 4969474d 3e6e77db     a&g...`.MGiI.wn>
    1540:	aed16a4a d9d65adc 40df0b66 37d83bf0     Jj...Z..f..@.;.7
    1550:	a9bcae53 debb9ec5 47b2cf7f 30b5ffe9     S..........G...0
    1560:	bdbdf21c cabac28a 53b39330 24b4a3a6     ........0..S...$
    1570:	bad03605 cdd70693 54de5729 23d967bf     .6......)W.T.g.#
    1580:	b3667a2e c4614ab8 5d681b02 2a6f2b94     .zf..Ja...h].+o*
    1590:	b40bbe37 c30c8ea1 5a05df1b 2d02ef8d     7..........Z...-
