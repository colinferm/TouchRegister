//
//  ViewController.swift
//  Touch Register
//
//  Created by Colin Ferm on 8/3/20.
//  Copyright © 2020 42 Solutions, LLC. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

struct TouchTrack {
    var num: Int
    var point: CGPoint
    var timestampStart: NSDate
	var timestampEnd: NSDate?
	var color: UIColor?
}

class ViewController: UIViewController {
	static let COLORS = [
		UIColor(named: "red-one"),
		UIColor(named: "aqua-one"),
		UIColor(named: "green-one"),
		UIColor(named: "red-three"),
		UIColor(named: "aqua-three"),
		UIColor(named: "green-three"),
		UIColor(named: "red-four"),
		UIColor(named: "aqua-four"),
		UIColor(named: "green-four"),
		UIColor(named: "red-two"),
		UIColor(named: "aqua-two"),
		UIColor(named: "green-two"),
		UIColor(named: "red-five"),
		UIColor(named: "aqua-five"),
		UIColor(named: "green-five")
	]
	
	
    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var touchCountLabel: UILabel!
	@IBOutlet weak var clearButton: UIButton!
	
    var num: Int = 0
    var touches = [TouchTrack]()
    var touch: TouchTrack?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.touchCountLabel.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self.view)
            if self.touch == nil {
                self.touch = TouchTrack(num: self.num, point: touchPoint, timestampStart: NSDate())
				let mod = self.num % ViewController.COLORS.count
				self.touch?.color = ViewController.COLORS[mod]
            }
        }
    }
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.endTouch(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.endTouch(touches, with: event)
	}
	
	private func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
		if var currentTouch = self.touch {
			currentTouch.timestampEnd = NSDate()
			self.num += 1
			self.touchCountLabel.text = "Tracked \(self.num) Touches"
			self.touchCountLabel.textColor = currentTouch.color
			self.drawTouch(currentTouch)
			self.touches.append(currentTouch)
			self.touch = nil
		}
	}
	
	private func drawTouch(_ touch: TouchTrack) {
		UIGraphicsBeginImageContext(view.frame.size)
		let context = UIGraphicsGetCurrentContext()
		if let currentImage = self.imageView.image {
			currentImage.draw(in: self.view.bounds)
		}
		context?.move(to: touch.point)
		context?.setLineCap(.round)
		context?.setFillColor(touch.color!.cgColor)
		context?.setStrokeColor(touch.color!.cgColor)
		context?.setBlendMode(.normal)
		
		let point = CGPoint(x: touch.point.x - 25, y: touch.point.y - 25)
		let rect = CGRect(origin: point, size: CGSize(width: 50, height: 50))
		context?.fillEllipse(in: rect)
		//context?.strokeEllipse(in: CGRect(origin: touch.point, size: CGSize(width: 50, height: 50)))
		
		let paraStyle = NSMutableParagraphStyle()
		paraStyle.alignment = .center
		let attr: [NSAttributedString.Key : Any] = [
			.paragraphStyle: paraStyle,
			.font: UIFont.systemFont(ofSize: 12.0, weight: .bold),
			.foregroundColor: UIColor.white
		]
		let attrString = NSAttributedString(string: "\(touch.num + 1)", attributes: attr)
		attrString.draw(in: CGRect(origin: CGPoint(x: touch.point.x - 10.0, y: touch.point.y - 7.5), size: CGSize(width: 20, height: 15)))
		
		self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		let emitter = CAEmitterLayer()
		emitter.emitterPosition = touch.point
		emitter.emitterSize = CGSize(width: 10, height: 10)
		
		let cell = CAEmitterCell()
		cell.spin = 1.5
		cell.spinRange = 5
		cell.birthRate = 200
		cell.lifetime = 1.5
		cell.lifetimeRange = 3
		cell.color = touch.color!.cgColor
		cell.contents = UIImage(named: "fire")?.cgImage
		cell.velocity = 50
		cell.velocityRange = 100
		cell.scale = 0.75
		cell.scaleRange = 1.0
		cell.scaleSpeed = -0.2
		//cell.emissionRange = .pi / 2
		cell.emissionRange = .pi
		
		emitter.emitterCells = [cell]
		emitter.renderMode = .additive
		self.imageView.layer.addSublayer(emitter)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			emitter.removeFromSuperlayer()
		}
	}
	
	@IBAction func clearScreen(_sender: UIButton) {
		self.touches.removeAll()
		self.imageView.image = nil
		self.num = 0
		self.touchCountLabel.text = ""
	}

}

