"""Deterministic tissue phantom; mechanical smoke fixture, not efficacy evidence."""
import sys
from pathlib import Path
import numpy as np
import nibabel as nib
root = Path(sys.argv[1]); root.mkdir(parents=True, exist_ok=True)
i,j,k = np.indices((48,48,48)); r = ((i-24)/18)**2 + ((j-24)/20)**2 + ((k-24)/17)**2
rng = np.random.default_rng(416)
x = np.where(r < .35, 110., np.where(r < .72, 75., np.where(r < 1, 35., np.where(r < 1.2, 130., 0.))))
x = np.where(x > 0, x * np.exp(.15*(i-24)/24) + rng.normal(0, 1, x.shape), 0).astype('float32')
affine = np.diag([2.,2.,2.,1.]); affine[:3,3] = [-48,-48,-48]
def save(data, name):
    img=nib.Nifti1Image(data, affine); img.set_qform(affine, 1); img.set_sform(affine, 1); nib.save(img, root/name)
save(x, 't1.nii.gz')
save((r < 1).astype('uint8'), 'mask.nii.gz')
save(np.stack([np.roll(x,d,axis=0) for d in (0,1,0)],axis=3), 'bold.nii.gz')
