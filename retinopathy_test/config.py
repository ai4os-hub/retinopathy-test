# -*- coding: utf-8 -*-
from os import path
import tensorflow as tf

# identify basedir for the package
BASE_DIR = path.dirname(path.normpath(path.dirname(__file__)))

# default location for input and output data, e.g. directories 'data' and 'models',
# is either set relative to the application path or via environment setting
IN_OUT_BASE_DIR = BASE_DIR
if 'APP_INPUT_OUTPUT_BASE_DIR' in os.environ:
    env_in_out_base_dir = os.environ['APP_INPUT_OUTPUT_BASE_DIR']
    if os.path.isdir(env_in_out_base_dir):
        IN_OUT_BASE_DIR = env_in_out_base_dir
    else:
        msg = "[WARNING] \"APP_INPUT_OUTPUT_BASE_DIR=" + \
        "{}\" is not a valid directory! ".format(env_in_out_base_dir) + \
        "Using \"BASE_DIR={}\" instead.".format(BASE_DIR)
        print(msg)
 
# Retina_RemoteStorage = 'rshare:/deep-oc-apps/retinopathy_test'
Retina_RemoteStorage = 'rshare:/retinopathy_test'
Retina_RemotePublic = 'https://nc.deep-hybrid-datacloud.eu/s/yNsYpACAFbFS8Rp/download?path='
Retina_RemoteDataRecords = path.join(Retina_RemoteStorage, 'data', 'records')
Retina_RemoteModelsUpload = path.join(Retina_RemoteStorage, 'models')
#Retina_LocalDataRecords = path.join(BASE_DIR, 'data', 'records')
#Retina_LocalModels = path.join(BASE_DIR, 'models')
Retina_LocalDataRecords = path.join(IN_OUT_BASE_DIR, 'data', 'records')
Retina_LocalModels = path.join(IN_OUT_BASE_DIR, 'models')

Retina_LocalModelsServe = path.join(Retina_LocalModels, 'retinopathy_serve')
Retina_TrainingData = "retinopathy_tr.tfrecords"
Retina_ValidationData = "retinopathy_va.tfrecords"

train_args = { 'train_epochs': {'default': 10,
                              'help': 'Number of epochs to train on',
                              'required': False
                             },
               'batch_size': {'default': 16,
                              'help': 'Global Batch size',
                              'required': False
                              },
               'num_gpus':   {'default': 1 if tf.test.is_gpu_available() else 0,
                              'help': 'Number of GPUs to use, if available (0 = CPU)',
                              'required': False
                             },
               'upload_back': {'default': False,
                               'choices': [False, True],
                               'help': 'Either upload a trained graph back to the remote storage (True) or not (False, default)',
                               'required': False
                              },
}
predict_args = {'trained_graph':   {'default': '1540408813_cpu',
                             'choices': ['1540408813_cpu', '1533577729_gpu'],
                             'help': 'Pre-trained graph to use',
                             'required': False
                           },

}
