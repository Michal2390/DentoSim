//
//  ProcedureData.swift
//  DentoSim XR
//
//  Created by Michal Fereniec on 17/11/2025.
//

import Foundation

struct ProcedureData {
    static let allModules: [ProcedureModule] = [
        toothExtractionModule,
        cavityRepairModule,
        dentalExaminationModule,
        rootCanalModule
    ]
    
    static let toothExtractionModule = ProcedureModule(
        id: "extraction_wisdom",
        title: "Wisdom Tooth Extraction",
        description: "Learn the proper technique for extracting a third molar (wisdom tooth) with minimal trauma to surrounding tissue.",
        difficulty: .advanced,
        estimatedTime: 15,
        steps: [
            ProcedureStep(
                id: "step1",
                instruction: "Administer local anesthesia around tooth #18",
                tool: .syringe,
                targetArea: "Gingival tissue near tooth 18",
                tip: "Insert needle at 45° angle, aspirate before injecting",
                warningThreshold: 0.8
            ),
            ProcedureStep(
                id: "step2",
                instruction: "Use elevator to loosen the tooth",
                tool: .elevator,
                targetArea: "Tooth #18 - mesial side",
                tip: "Apply gentle, controlled pressure in a rocking motion",
                warningThreshold: 0.7
            ),
            ProcedureStep(
                id: "step3",
                instruction: "Position forceps on the tooth crown",
                tool: .forceps,
                targetArea: "Tooth #18 crown",
                tip: "Grip firmly at the cemento-enamel junction",
                warningThreshold: nil
            ),
            ProcedureStep(
                id: "step4",
                instruction: "Apply controlled extraction force",
                tool: .forceps,
                targetArea: "Tooth #18",
                tip: "Use slow, steady pressure - avoid jerking motions",
                warningThreshold: 0.9
            ),
            ProcedureStep(
                id: "step5",
                instruction: "Examine the extracted tooth for completeness",
                tool: .mirror,
                targetArea: "Extracted tooth",
                tip: "Verify all roots are intact",
                warningThreshold: nil
            )
        ],
        targetTooth: 18
    )
    
    static let cavityRepairModule = ProcedureModule(
        id: "cavity_class1",
        title: "Class I Cavity Preparation",
        description: "Master the preparation and restoration of an occlusal cavity on a molar tooth.",
        difficulty: .intermediate,
        estimatedTime: 12,
        steps: [
            ProcedureStep(
                id: "step1",
                instruction: "Examine the tooth surface with a mirror",
                tool: .mirror,
                targetArea: "Tooth #19 occlusal surface",
                tip: "Look for discoloration and surface defects",
                warningThreshold: nil
            ),
            ProcedureStep(
                id: "step2",
                instruction: "Use explorer to detect cavity extent",
                tool: .explorer,
                targetArea: "Tooth #19 fissures",
                tip: "Gently probe to assess softened dentin",
                warningThreshold: 0.6
            ),
            ProcedureStep(
                id: "step3",
                instruction: "Remove decayed tissue with excavator",
                tool: .excavator,
                targetArea: "Tooth #19 cavity",
                tip: "Work from outside edges toward the center",
                warningThreshold: 0.7
            ),
            ProcedureStep(
                id: "step4",
                instruction: "Shape cavity walls with drill",
                tool: .drill,
                targetArea: "Tooth #19 cavity preparation",
                tip: "Maintain proper angulation for retention form",
                warningThreshold: 0.8
            ),
            ProcedureStep(
                id: "step5",
                instruction: "Verify cavity preparation",
                tool: .explorer,
                targetArea: "Prepared cavity",
                tip: "Check for smooth walls and complete caries removal",
                warningThreshold: nil
            )
        ],
        targetTooth: 19
    )
    
    static let dentalExaminationModule = ProcedureModule(
        id: "exam_basic",
        title: "Basic Dental Examination",
        description: "Practice systematic examination of the oral cavity using fundamental diagnostic instruments.",
        difficulty: .beginner,
        estimatedTime: 8,
        steps: [
            ProcedureStep(
                id: "step1",
                instruction: "Begin visual inspection with mirror",
                tool: .mirror,
                targetArea: "Upper arch - buccal surfaces",
                tip: "Use systematic approach: start from posterior right",
                warningThreshold: nil
            ),
            ProcedureStep(
                id: "step2",
                instruction: "Examine occlusal surfaces",
                tool: .mirror,
                targetArea: "All molars and premolars",
                tip: "Look for caries, wear patterns, and restorations",
                warningThreshold: nil
            ),
            ProcedureStep(
                id: "step3",
                instruction: "Check for calculus with explorer",
                tool: .explorer,
                targetArea: "Lower anterior teeth - lingual",
                tip: "Feel for rough deposits near gingival margin",
                warningThreshold: 0.5
            ),
            ProcedureStep(
                id: "step4",
                instruction: "Assess periodontal health",
                tool: .explorer,
                targetArea: "Gingival sulcus",
                tip: "Note bleeding, inflammation, or pocket depth",
                warningThreshold: 0.6
            )
        ],
        targetTooth: nil
    )
    
    static let rootCanalModule = ProcedureModule(
        id: "endo_basic",
        title: "Root Canal Access Opening",
        description: "Learn to create proper access cavity for endodontic treatment of a maxillary molar.",
        difficulty: .advanced,
        estimatedTime: 18,
        steps: [
            ProcedureStep(
                id: "step1",
                instruction: "Visualize pulp chamber anatomy",
                tool: .mirror,
                targetArea: "Tooth #3 occlusal surface",
                tip: "Pulp chamber is wider mesio-distally in maxillary molars",
                warningThreshold: nil
            ),
            ProcedureStep(
                id: "step2",
                instruction: "Create outline form with drill",
                tool: .drill,
                targetArea: "Tooth #3 central occlusal area",
                tip: "Start at the center of the occlusal surface",
                warningThreshold: 0.9
            ),
            ProcedureStep(
                id: "step3",
                instruction: "Remove roof of pulp chamber",
                tool: .drill,
                targetArea: "Pulp chamber ceiling",
                tip: "Work carefully to avoid perforating chamber floor",
                warningThreshold: 0.95
            ),
            ProcedureStep(
                id: "step4",
                instruction: "Locate canal orifices with explorer",
                tool: .explorer,
                targetArea: "Pulp chamber floor",
                tip: "Typically 3-4 canals in maxillary first molar",
                warningThreshold: 0.6
            )
        ],
        targetTooth: 3
    )
}