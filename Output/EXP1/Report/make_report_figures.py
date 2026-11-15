import os, numpy as np, scipy.io as sio, re, matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
B=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..','..','..','Lab Data','EXP1','LabDay2') + os.sep # updated in the Sep 2026 folder reorg (was a stale cloud-upload path)
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':9,'axes.edgecolor':'#52514e','axes.labelcolor':'#0b0b0b','xtick.color':'#52514e','ytick.color':'#52514e','axes.spines.top':False,'axes.spines.right':False,'axes.grid':True,'grid.color':'#e4e3df','grid.linewidth':0.6})
BLUE,ORANGE,AQUA='#2a78d6','#eb6834','#1baf7a'
m=sio.loadmat(B+'TestsWithDotMAT/Bifolar1.MAT',squeeze_me=True,struct_as_record=False)['UFCELLS']
x=np.asarray(m[2].DataValues,float); dt=m[2].AbscissaIncrement; t=np.arange(x.size)*dt
txt=open(B+'Bifolar1Arduino.txt').read()
ax_=np.array([float(v) for v in re.search(r'X\s*=\s*\[([^\]]*)\]',txt).group(1).split()])
ta=np.arange(ax_.size)*(1.833/ax_.size)
def spec(sig,fs):
    s=sig-np.polyval(np.polyfit(np.arange(sig.size),sig,1),np.arange(sig.size)); w=np.hanning(s.size)
    n=2**int(np.ceil(np.log2(16*s.size))); P=np.abs(np.fft.rfft(s*w,n))**2; f=np.fft.rfftfreq(n,1/fs); return f,P/P[(f>0.3)&(f<6)].max()
b,a=butter(4,10/(0.5/dt)); xd=x-np.mean(x); xf=filtfilt(b,a,xd)
fig,axs=plt.subplots(3,1,figsize=(6.5,6.2),constrained_layout=True)
axs[0].plot(t,xd*1000,color='#b9b8b3',lw=0.6,label='Raw (mean removed)')
axs[0].plot(t,xf*1000,color=BLUE,lw=1.6,label='10 Hz low-pass (display only)')
axs[0].set_xlabel('Time (s)'); axs[0].set_ylabel('Acceleration (mg)'); axs[0].set_title('(a) Commercial IEPE / X-Modal, 8 kHz, channel 1',loc='left',fontsize=9)
axs[0].legend(frameon=False,fontsize=8,loc='upper right',ncol=2)
axs[1].plot(ta,ax_-ax_.mean(),color=ORANGE,lw=1.4)
axs[1].set_xlabel('Time (s)'); axs[1].set_ylabel('Acceleration (counts)'); axs[1].set_title('(b) Arduino MPU-6050, x channel, 2048 samples over ~1.833 s',loc='left',fontsize=9)
f1,P1=spec(x,1/dt); f2,P2=spec(ax_,2048/1.833)
axs[2].plot(f1,P1,color=BLUE,lw=1.8,label='X-Modal')
axs[2].plot(f2,P2,color=ORANGE,lw=1.8,label='Arduino')
axs[2].set_xlim(0,5); axs[2].set_ylim(0,1.08); axs[2].set_xlabel('Frequency (Hz)'); axs[2].set_ylabel('Normalized power')
axs[2].set_title('(c) Hann-windowed, zero-padded spectra',loc='left',fontsize=9)
axs[2].axvline(1.7115,color='#52514e',lw=0.8,ls='--'); axs[2].axvline(2*1.7115,color='#52514e',lw=0.8,ls=':')
axs[2].text(1.75,1.0,'f ≈ 1.71–1.72 Hz (twist)',fontsize=8,color='#0b0b0b'); axs[2].text(3.47,0.85,'2f ≈ 3.46 Hz\n(vertical bounce)',fontsize=8,color='#0b0b0b')
axs[2].legend(frameon=False,fontsize=8,loc='center right')
fig.savefig('fig/fig_signal_bifilar1.png',dpi=220)
# comparison figure
labels=['Config 1 · Izz\nbifilar (Arduino + X-Modal)','Config 2 · Iyy\ncompound (X-Modal)','Config 3 · Ixx\ncompound (X-Modal)']
exp=[-13.12,-8.45,-6.84]; unc=[5.24,46.96,6.64]
nx=[0.05,0.03,-5.01]  # NX scaled to measured mass vs analytical (%) computed below
fig,ax=plt.subplots(figsize=(6.5,3.4),constrained_layout=True)
y=np.arange(3)[::-1]
ax.axvline(0,color='#0b0b0b',lw=1)
ax.errorbar(exp,y,xerr=unc,fmt='o',ms=8,color=ORANGE,ecolor=ORANGE,elinewidth=1.6,capsize=4,label='Experimental ± propagated uncertainty')
ax.plot(nx,y-0.18,'s',ms=8,color=BLUE,label='NX (scaled to measured mass)',mec='white',mew=1.5)
for yi,e,l in zip(y,exp,['−13.1%','−8.5%','−6.8%']): ax.text(e,yi+0.2,l,ha='center',fontsize=8,color='#0b0b0b')
ax.set_yticks(y); ax.set_yticklabels(labels,fontsize=8); ax.set_xlim(-60,45); ax.set_ylim(-0.6,2.6)
ax.set_xlabel('Difference from analytical model, (I − I_analytical)/I_analytical (%)')
ax.legend(frameon=False,fontsize=8,loc='lower center',bbox_to_anchor=(0.5,1.0),ncol=2); ax.grid(axis='y',visible=False)
fig.savefig('fig/fig_comparison.png',dpi=220)
print('ok', 'xmodal 2f check')
