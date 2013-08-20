-- #hide
-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.OpenGL.GL.FramebufferObjects.RendebufferObjects
-- Copyright   :
-- License     :  BSD3
--
-- Maintainer  :  Sven Panne <sven.panne@aedion.de>
-- Stability   :
-- Portability :
--
-----------------------------------------------------------------------------

module Graphics.Rendering.OpenGL.GL.FramebufferObjects.RenderbufferObjects (
   RenderbufferObject,
   noRenderbufferObject,
   RenderbufferTarget(..), marshalRenderbufferTarget,
   RenderbufferSize(..), Samples(..),

   bindRenderbuffer,

   renderbufferStorage, renderbufferStorageMultiSample,

   getRBParameteriv,
) where

import Foreign.Marshal
import Graphics.Rendering.OpenGL.GL.FramebufferObjects.RenderbufferObject
import Graphics.Rendering.OpenGL.GL.PeekPoke
import Graphics.Rendering.OpenGL.GL.QueryUtils
import Graphics.Rendering.OpenGL.GL.StateVar
import Graphics.Rendering.OpenGL.GL.Texturing.PixelInternalFormat
import Graphics.Rendering.OpenGL.Raw.Core31

-----------------------------------------------------------------------------

noRenderbufferObject :: RenderbufferObject
noRenderbufferObject = RenderbufferObject 0

-----------------------------------------------------------------------------

data RenderbufferTarget =
   Renderbuffer

marshalRenderbufferTarget :: RenderbufferTarget -> GLenum
marshalRenderbufferTarget x = case x of
    Renderbuffer -> gl_RENDERBUFFER

marshalRenderbufferTargetBinding :: RenderbufferTarget -> PName1I
marshalRenderbufferTargetBinding x = case x of
    Renderbuffer -> GetRenderbufferBinding
-----------------------------------------------------------------------------

data RenderbufferSize = RenderbufferSize !GLsizei !GLsizei

newtype Samples = Samples GLsizei

-----------------------------------------------------------------------------

bindRenderbuffer :: RenderbufferTarget -> StateVar RenderbufferObject
bindRenderbuffer rbt =
    makeStateVar (getBoundRenderbuffer rbt) (setRenderbuffer rbt)

getBoundRenderbuffer :: RenderbufferTarget -> IO RenderbufferObject
getBoundRenderbuffer = getInteger1 (RenderbufferObject . fromIntegral)
   . marshalRenderbufferTargetBinding

setRenderbuffer :: RenderbufferTarget -> RenderbufferObject -> IO ()
setRenderbuffer rbt = glBindRenderbuffer (marshalRenderbufferTarget rbt)
   . renderbufferID

-----------------------------------------------------------------------------

renderbufferStorageMultiSample :: RenderbufferTarget -> Samples
   -> PixelInternalFormat -> RenderbufferSize -> IO ()
renderbufferStorageMultiSample rbt (Samples s) pif (RenderbufferSize w h) =
   glRenderbufferStorageMultisample (marshalRenderbufferTarget rbt) s
       (marshalPixelInternalFormat' pif) w h


renderbufferStorage :: RenderbufferTarget -> PixelInternalFormat
   -> RenderbufferSize -> IO ()
renderbufferStorage rbt pif (RenderbufferSize w h) =
    glRenderbufferStorage (marshalRenderbufferTarget rbt)
       (marshalPixelInternalFormat' pif) w h

-----------------------------------------------------------------------------

getRBParameteriv :: RenderbufferTarget -> (GLint -> a) -> GLenum -> IO a
getRBParameteriv rbt f p = alloca $ \buf -> do
   glGetRenderbufferParameteriv (marshalRenderbufferTarget rbt)
      p buf
   peek1 f buf
