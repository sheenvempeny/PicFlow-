//
//  VideoExporter.swift
//  PicFlow++
//
//  Created by Sheen on 3/18/15.
//  Copyright (c) 2015 Sheen. All rights reserved.
//

import Foundation
import CoreVideo
import AssetsLibrary
import CoreMedia
import AVFoundation

class VideoExporter: NSObject
{
    
    var project:Project?
    var outputFile:NSURL?
    var movieSize:CGSize?
    
    func pixelBufferFromCGImage(image:CGImageRef,withSize frameSize:CGSize) -> CVPixelBufferRef?
    {
        let options = [
            "kCVPixelBufferCGImageCompatibilityKey": true,
            "kCVPixelBufferCGBitmapContextCompatibilityKey": true
        ]
        
        var pixelBufferPointer = UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>.alloc(1)
        var status:CVReturn = CVPixelBufferCreate(
            kCFAllocatorDefault,
            UInt(frameSize.width),
            UInt(frameSize.height),
            OSType(kCVPixelFormatType_32ARGB),
            options,
            pixelBufferPointer
        )
        
        var lockStatus:CVReturn = CVPixelBufferLockBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue(), 0)
        var pxData:UnsafeMutablePointer<(Void)> = CVPixelBufferGetBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue())
        let bitmapinfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
        let rgbColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        var context:CGContextRef = CGBitmapContextCreate(
            pxData,
            UInt(frameSize.width),
            UInt(frameSize.height),
            8,
            4 * CGImageGetWidth(image),
            rgbColorSpace,
            bitmapinfo
        )
        
        CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), image)
        CVPixelBufferUnlockBaseAddress(pixelBufferPointer.memory?.takeUnretainedValue(), 0)
        return pixelBufferPointer.memory?.takeUnretainedValue()
    }
    
    func appendToAdapter(adaptor:AVAssetWriterInputPixelBufferAdaptor,
        pixelBuffer buffer:CVPixelBufferRef,
        atTime presentTime:CMTime,
        withInput writerInput:AVAssetWriterInput) -> Bool
    {
   
        while (!writerInput.readyForMoreMediaData) {
            usleep(1);
        }
        
        
        return adaptor.appendPixelBuffer(buffer, withPresentationTime: presentTime)
    }
    

    
    func export()
    {
        //https://github.com/HarrisonJackson/HJImagesToVideo/blob/master/ImageToVid/HJImagesToVideo/HJImagesToVideo.m
        
        var fps:Int32?
        var error: NSError?;
        var videoWriter:AVAssetWriter? = AVAssetWriter(URL: outputFile, fileType: AVFileTypeMPEG4, error: &error)
        
        if (error != nil) {
           
            return;
        }
        var videoSettings = Dictionary<String, AnyObject!>()
        videoSettings = [AVVideoCodecKey:AVVideoCodecH264, AVVideoWidthKey:movieSize?.width, AVVideoHeightKey:movieSize?.height]
        var writerInput:AVAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        var adaptor:AVAssetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes:nil);
        
        if(videoWriter?.canAddInput(writerInput) == false){
            
            return;
        }
        
        videoWriter?.addInput(writerInput)
        //Start a session:
        videoWriter?.startWriting()
        videoWriter?.startSessionAtSourceTime(kCMTimeZero)
       
        var buffer:CVPixelBufferRef?;
        var presentTime:CMTime = CMTimeMake(0, fps!);
        
        var i:Int64 = 0;
        while (i >= 0)
        {
            if(writerInput.readyForMoreMediaData){
                presentTime = CMTimeMake(i, fps!);
                
                if (Int(i) >= project?.frames.count) {
                    buffer = nil;
                }
                else {
                    var frame:Frame = project?.frames[Int(i)] as Frame!
                    buffer = self.pixelBufferFromCGImage(frame.image().CGImage, withSize: movieSize!)
                }
                
                if (buffer != nil) {
                
                    var appendSuccess:Bool = self.appendToAdapter(adaptor, pixelBuffer: buffer!, atTime: presentTime, withInput: writerInput)
                    if(appendSuccess == false){
                        return;
                    }
                    
                    
                    i++;
            }
            else {
            
                    //Finish the session:
                    writerInput.markAsFinished()
                    videoWriter?.finishWritingWithCompletionHandler({
                    
                        if (videoWriter!.status == AVAssetWriterStatus.Completed) {
                            
                        }
                        else{
                            
                            
                        }
                    
                    })
                 
                    break;
                }
                
                }//writerInput.readyForMoreMediaData
        }//while
    }
    
    /*
    http://stackoverflow.com/questions/25611086/cvpixelbufferpool-error-kcvreturninvalidargument-6661
    
    func writeAnimationToMovie(path: String, size: CGSize, animation: Animation) -> Bool {
        var error: NSError?
        let writer = AVAssetWriter(URL: NSURL(fileURLWithPath: path), fileType: AVFileTypeQuickTimeMovie, error: &error)
        
        let videoSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: size.width, AVVideoHeightKey: size.height]
        
        let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        input.expectsMediaDataInRealTime = true
        writer.addInput(input)
        
        writer.startWriting()
        writer.startSessionAtSourceTime(kCMTimeZero)
        
        var buffer: CVPixelBufferRef
        
        var frameCount = 0
        for frame in animation.frames {
            let rect = CGRectMake(0, 0, size.width, size.height)
            let rectPtr = UnsafeMutablePointer<CGRect>.alloc(1)
            rectPtr.memory = rect
            buffer = pixelBufferFromCGImage(frame.image.CGImageForProposedRect(rectPtr, context: nil, hints: nil).takeUnretainedValue(), size)
            var appendOk = false
            var j = 0
            while (!appendOk && j < 30) {
                if pixelBufferAdaptor.assetWriterInput.readyForMoreMediaData {
                    let frameTime = CMTimeMake(Int64(frameCount), 10)
                    appendOk = pixelBufferAdaptor.appendPixelBuffer(buffer, withPresentationTime: frameTime)
                    // appendOk will always be false
                    NSThread.sleepForTimeInterval(0.05)
                } else {
                    NSThread.sleepForTimeInterval(0.1)
                }
                j++
            }
            if (!appendOk) {
                println("Doh, frame \(frame) at offset \(frameCount) failed to append")
            }
        }
        
        input.markAsFinished()
        writer.finishWritingWithCompletionHandler({
            if writer.status == AVAssetWriterStatus.Failed {
                println("oh noes, an error: \(writer.error.description)")
            } else {
                println("hrmmm, there should be a movie?")
            }
        })
        
        return true;
    }
    */
}