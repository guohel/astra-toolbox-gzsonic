#-----------------------------------------------------------------------
#Copyright 2013 Centrum Wiskunde & Informatica, Amsterdam
#
#Author: Daniel M. Pelt
#Contact: D.M.Pelt@cwi.nl
#Website: http://dmpelt.github.io/pyastratoolbox/
#
#
#This file is part of the Python interface to the
#All Scale Tomographic Reconstruction Antwerp Toolbox ("ASTRA Toolbox").
#
#The Python interface to the ASTRA Toolbox is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#The Python interface to the ASTRA Toolbox is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with the Python interface to the ASTRA Toolbox. If not, see <http://www.gnu.org/licenses/>.
#
#-----------------------------------------------------------------------
# distutils: language = c++
# distutils: libraries = astra

import six
from .PyIncludes cimport *

cimport utils
from .utils import wrap_from_bytes

cimport PyProjector3DFactory
from .PyProjector3DFactory cimport CProjector3DFactory

cimport PyProjector3DManager
from .PyProjector3DManager cimport CProjector3DManager

cimport PyXMLDocument
from .PyXMLDocument cimport XMLDocument

cdef CProjector3DManager * manProj = <CProjector3DManager * >PyProjector3DManager.getSingletonPtr()

include "config.pxi"

IF HAVE_CUDA:
  cdef extern from *:
      CCudaProjector3D* dynamic_cast_cuda_projector "dynamic_cast<astra::CCudaProjector3D*>" (CProjector3D*)


def create(config):
    cdef Config * cfg = utils.dictToConfig(six.b('Projector3D'), config)
    cdef CProjector3D * proj
    proj = PyProjector3DFactory.getSingletonPtr().create(cfg[0])
    if proj == NULL:
        del cfg
        raise Exception("Error creating Projector3D.")
    del cfg
    return manProj.store(proj)


def delete(ids):
    try:
        for i in ids:
            manProj.remove(i)
    except TypeError:
        manProj.remove(ids)


def clear():
    manProj.clear()


def info():
    six.print_(wrap_from_bytes(manProj.info()))

cdef CProjector3D * getObject(i) except NULL:
    cdef CProjector3D * proj = manProj.get(i)
    if proj == NULL:
        raise Exception("Projector not initialized.")
    if not proj.isInitialized():
        raise Exception("Projector not initialized.")
    return proj


def projection_geometry(i):
    cdef CProjector3D * proj = getObject(i)
    return utils.configToDict(proj.getProjectionGeometry().getConfiguration())


def volume_geometry(i):
    cdef CProjector3D * proj = getObject(i)
    return utils.configToDict(proj.getVolumeGeometry().getConfiguration())


def weights_single_ray(i, projection_index, detector_index):
    raise Exception("Not yet implemented")


def weights_projection(i, projection_index):
    raise Exception("Not yet implemented")


def splat(i, row, col):
    raise Exception("Not yet implemented")

def is_cuda(i):
    cdef CProjector3D * proj = getObject(i)
    IF HAVE_CUDA==True:
      cdef CCudaProjector3D * cudaproj = NULL
      cudaproj = dynamic_cast_cuda_projector(proj)
      if cudaproj==NULL:
          return False
      else:
          return True
    ELSE:
        return False
